require 'securerandom'

#
# Support for the specs that need a real RabbitMQ broker, i.e. those covering
# Startback::Event::Bus::Bunny::Async. There is no way to cover that bus
# meaningfully without one: mocking bunny would only assert that Startback
# calls the methods Startback calls.
#
# The broker is located through STARTBACK_BUS_BUNNY_ASYNC_URL, which is also
# the variable the bus itself reads, so pointing the suite at a broker and
# pointing an application at one are the same gesture.
#
#     STARTBACK_BUS_BUNNY_ASYNC_URL=amqp://guest:guest@localhost:5672
#
# `make rabbitmq.up` starts one locally. When no broker answers, those specs
# are skipped, so that a contributor without docker still gets a green suite.
#
# That skip is a trap on CI, where a broken service container would quietly
# take the coverage away instead of failing. STARTBACK_SPEC_REQUIRE_BUNNY=1
# turns "no broker" into a hard error, and CI sets it.
#
module BunnyBroker
  extend self

  DEFAULT_URL = "amqp://guest:guest@localhost:5672"

  def url
    ENV['STARTBACK_BUS_BUNNY_ASYNC_URL'] || DEFAULT_URL
  end

  def required?
    !ENV['STARTBACK_SPEC_REQUIRE_BUNNY'].to_s.strip.empty?
  end

  # Whether a broker answers, memoized: the specs ask once per example and
  # connecting is not free. `false` is a legitimate memoized answer, hence
  # `defined?` rather than `||=`.
  def available?
    return @available if defined?(@available)

    @available = begin
      require 'bunny'
      conn = ::Bunny.new(url, log_level: :fatal, network_recovery_interval: 0,
                              connection_timeout: 2, continuation_timeout: 4000)
      conn.start
      conn.close
      true
    rescue StandardError, LoadError => ex
      @unavailable_reason = "#{ex.class}: #{ex.message}"
      false
    end
  end

  def unavailable_reason
    @unavailable_reason
  end

  # Called from a `before` hook, with the example context as argument --
  # `skip` is a method of the example group instance, not of the Example
  # object, whose own `skip` is a metadata reader taking no argument.
  def skip_unless_available!(context)
    return if available?

    msg = "No RabbitMQ broker at #{url} (#{unavailable_reason})"
    raise "#{msg}. STARTBACK_SPEC_REQUIRE_BUNNY is set, so this is an error." if required?

    context.skip("#{msg}. Start one with `make rabbitmq.up`.")
  end

  # Exchanges and queues outlive an example now that both are durable, and
  # redeclaring one with different options raises PreconditionFailed. Each
  # example therefore works on names nobody else uses.
  def unique(prefix)
    "#{prefix}-#{SecureRandom.hex(6)}"
  end

  # Removes the topology an example created. Durable means the broker would
  # otherwise keep it forever.
  def delete_topology(exchanges: [], queues: [])
    conn = ::Bunny.new(url, log_level: :fatal)
    conn.start
    ch = conn.create_channel
    queues.each    { |q| ch.queue_delete(q) rescue nil }
    exchanges.each { |x| ch.exchange_delete(x) rescue nil }
    conn.close
  rescue StandardError
    # Best effort: a cleanup failure must not turn a passing example red.
  end

  # Whether the broker still lets a *transient non-exclusive queue* be
  # declared. RabbitMQ denies that from 4.3 on, which is the very reason the
  # durable defaults exist -- but it also means the queue half of the
  # adoption path cannot be set up on such a broker. Exchanges are not
  # restricted, so that half is always exercised.
  def transient_queues_permitted?
    return @transient_queues if defined?(@transient_queues)

    @transient_queues = begin
      conn = ::Bunny.new(url, log_level: :fatal, continuation_timeout: 4000)
      conn.start
      name = unique("probe-transient")
      begin
        ch = conn.create_channel
        ch.queue(name, {})
        ch.queue_delete(name)
        true
      rescue StandardError
        false
      ensure
        conn.close rescue nil
      end
    rescue StandardError
      false
    end
  end

  # Same trap as skip_unless_available!, one level down: on the CI job whose
  # whole point is to run the adoption examples, a broker image bumped past
  # 4.2 would make them skip and take the coverage away silently.
  def skip_unless_transient_queues!(context)
    return if transient_queues_permitted?

    msg = "Broker at #{url} denies transient non-exclusive queues " \
          "(RabbitMQ >= 4.3), so the legacy topology cannot be created here"
    if !ENV['STARTBACK_SPEC_REQUIRE_TRANSIENT_QUEUES'].to_s.strip.empty?
      raise "#{msg}. STARTBACK_SPEC_REQUIRE_TRANSIENT_QUEUES is set, so this " \
            "is an error: this job exists to run these examples."
    end

    context.skip("#{msg}. The bus-legacy CI job covers it against RabbitMQ 4.1.")
  end

  # Blocks until `bl` returns something truthy, or the timeout expires.
  # Returns the value, or nil. Polling rather than sleeping a fixed delay
  # keeps the suite fast when the broker is responsive, which it usually is.
  def wait_for(timeout = 10, &bl)
    deadline = Time.now + timeout
    while Time.now < deadline
      value = bl.call
      return value if value
      sleep 0.05
    end
    nil
  end
end
