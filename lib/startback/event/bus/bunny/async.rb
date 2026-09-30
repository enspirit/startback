require 'bunny'
module Startback
  class Event
    class Bus
      module Bunny
        #
        # Asynchronous implementation of the bus abstraction, on top of RabbitMQ
        # and using the 'bunny' gem.
        #
        # This bus implementation emits events by dumping them to RabbitMQ using
        # the event type as exchange name. Listeners may use the `processor`
        # parameter to specify the queue name ; otherwise a default "main" queue
        # is used.
        #
        # WARNING: unlike Bus::Memory::Async, which hands listeners an Event
        # instance, this bus hands them the **raw JSON String** read off the
        # queue. A listener moved from the memory bus to this one therefore
        # receives something else, silently. Parse it yourself, e.g. with
        # `Startback::Event.json(body, context)`.
        #
        # The exchange and queue are declared **durable** by default. RabbitMQ
        # refuses transient non-exclusive queues from 4.3 on, so the previous
        # defaults stop working there entirely.
        #
        # An exchange or queue that already exists with other properties -- one
        # an older Startback declared transient -- is **adopted as it stands**
        # rather than redeclared, so upgrading needs no broker-side migration.
        # A warning is logged, and the durable declaration takes effect on its
        # own at the next broker restart, transient objects not surviving one.
        #
        # Examples:
        #
        #     # Connects to RabbitMQ using all default options
        #     #
        #     # Uses the STARTBACK_BUS_BUNNY_ASYNC_URL environment variable for
        #     # connection URL if present.
        #     Startback::Bus::Bunny::Async.new
        #
        #     # Connects to RabbitMQ using a specific URL
        #     Startback::Bus::Bunny::Async.new("amqp://rabbituser:rabbitpass@192.168.17.17")
        #     Startback::Bus::Bunny::Async.new(url: "amqp://rabbituser:rabbitpass@192.168.17.17")
        #
        #     # Connects to RabbitMQ using specific connection options. See Bunny's own
        #     # documentation
        #     Startback::Bus::Bunny::Async.new({
        #       connection_options: {
        #         host: "192.168.17.17"
        #       }
        #     })
        #
        class Async
          include Support::Robustness

          CHANNEL_KEY = 'Startback::Bus::Bunny::Async::ChannelKey'

          DEFAULT_OPTIONS = {
            # (optional) The URL to use for connecting to RabbitMQ.
            url: ENV['STARTBACK_BUS_BUNNY_ASYNC_URL'],

            # (optional) The options has to pass to ::Bunny constructor
            connection_options: nil,

            # (optional) The options to use for the emitter/listener fanout
            #
            # Durable by default, so that the exchange and the bindings
            # pointing at it survive a broker restart. A durable queue bound
            # to a transient exchange would come back alone, with nothing
            # routing to it.
            fanout_options: { durable: true },

            # (optional) The options to use for the listener queue
            #
            # Durable by default, because RabbitMQ 4 refuses transient
            # non-exclusive queues: declaring one fails the channel, and
            # `listen` never receives anything. Durability is also what a
            # named processor queue wants -- events waiting in it outlive a
            # broker restart rather than being dropped on the floor.
            queue_options: { durable: true },

            # (optional) Default event factory to use, if any
            event_factory: nil,

            # (optional) A default context to use for general logging
            context: nil,

            # (optional) Size of consumer pool
            consumer_pool_size: 1,

            # (optional) Whether the program must be aborted on consumption
            # error
            abort_on_exception: true,

            # (optional) Whether connection occurs immediately,
            # or on demand later
            autoconnect: false
          }

          # Creates a bus instance, using the various options provided to
          # fine-tune behavior.
          def initialize(options = {})
            options = { url: options } if options.is_a?(String)
            @options = DEFAULT_OPTIONS.merge(options)
            @topology = {}
            @topology_lock = Mutex.new
            connect if @options[:autoconnect]
          end
          attr_reader :options

          def connect
            disconnect
            # What the broker holds is only known for a given connection: a
            # restart in between wipes every transient exchange and queue.
            @topology_lock.synchronize { @topology = {} }
            conn = options[:connection_options] || options[:url]
            try_max_times(10) do
              @bunny = ::Bunny.new(conn)
              @bunny.start
              channel # make sure we already create the channel
              log(:info, {op: "#{self.class.name}#connect", op_data: conn}, options[:context])
            end
          end

          def disconnect
            if channel = Thread.current[CHANNEL_KEY]
              channel.close
              Thread.current[CHANNEL_KEY] = nil
            end
            @bunny.close if @bunny
          end

          def connected?
            @bunny && @bunny.connected?
          end

          def channel
            unless @bunny
              raise Startback::Errors::Error, "Please connect your bus first, or use autoconnect: true"
            end

            # A channel-level error closes the channel, and bunny does not
            # reopen it. Since this one is cached per thread, a single such
            # error used to leave the thread with a dead channel forever:
            # every later emit failed with "cannot use a closed channel",
            # whatever the event type, and `stop_errors` hid it. Dropping a
            # closed channel here is what makes the bus recover on its own.
            current = Thread.current[CHANNEL_KEY]
            current = nil unless current.nil? || current.open?

            Thread.current[CHANNEL_KEY] = current || @bunny.create_channel(
              nil,
              consumer_pool_size, # consumer_pool_size
              abort_on_exception? # consumer_pool_abort_on_exception
            )
          end

          def emit(event)
            stop_errors(self, "emit", event.context) do
              fanout = declare(:fanout, event.type.to_s, fanout_options)
              fanout.publish(event.to_json)
            end
          end

          def listen(type, processor = nil, listener = nil, &bl)
            raise ArgumentError, "A listener must be provided" unless listener || bl

            fanout = declare(:fanout, type.to_s, fanout_options)
            queue = declare(:queue, (processor || "main").to_s, queue_options)
            # Bound by name on purpose: declaring the queue may have renewed
            # the channel, in which case `fanout` belongs to a closed one.
            queue.bind(fanout.name)
            queue.subscribe do |delivery_info, properties, body|
              stop_errors(self, "listen") do
                (listener || bl).call(body)
              end
            end
          end

        protected

          # Declares an exchange (`kind` = :fanout) or a queue (:queue) with
          # `options`, adopting one that already exists with other properties
          # instead of failing on it.
          #
          # Startback used to declare both transient. AMQP refuses to
          # redeclare an object with different properties, so an application
          # upgrading to the durable defaults would get the broker closing its
          # channel with PRECONDITION_FAILED -- and, `emit` being wrapped in
          # `stop_errors`, would silently stop emitting rather than crash.
          #
          # Requiring a coordinated broker restart to avoid that is a poor
          # deal for something the upgrade gains nothing from, so adopt what
          # is there: `passive: true` matches an existing object whatever its
          # properties. Transient objects disappear at the next broker
          # restart anyway, and the durable declaration then wins on its own,
          # with nobody having had to do anything.
          def declare(kind, name, options)
            channel.public_send(kind, name, topology_options(kind, name, options))
          rescue ::Bunny::PreconditionFailed, ::Bunny::NotFound
            # The topology moved under us -- a broker restart took a transient
            # object away, or another application redeclared it. Forget what
            # was known of it and look again.
            forget_topology(kind, name)
            renew_channel!
            channel.public_send(kind, name, topology_options(kind, name, options))
          end

          # The options that actually work for `name`: the requested ones,
          # unless an incompatible object is already there, in which case
          # `passive: true`, which matches whatever its properties are.
          #
          # Memoized, because `emit` declares the exchange on every call and
          # the answer only changes across connections.
          def topology_options(kind, name, requested)
            key = [kind, name]
            @topology_lock.synchronize do
              return @topology[key] if @topology.key?(key)
            end
            probed = probe_topology(kind, name, requested)
            @topology_lock.synchronize { @topology[key] = probed }
          end

          def forget_topology(kind, name)
            @topology_lock.synchronize { @topology.delete([kind, name]) }
          end

          # Tries the requested options on a **scratch channel**, never on the
          # one the bus works with. A rejected declaration is a channel-level
          # error, and the broker closes the channel it happened on: probing
          # on the shared channel would take down every consumer registered
          # there, so emitting would silently unsubscribe the listeners.
          def probe_topology(kind, name, requested)
            scratch = @bunny.create_channel
            begin
              scratch.public_send(kind, name, requested)
              requested
            rescue ::Bunny::PreconditionFailed
              log(:warn, {
                op: "#{self.class.name}#declare",
                op_data: {
                  kind: kind,
                  name: name,
                  msg: "Adopting an existing #{kind} whose properties differ " \
                       "from the requested ones. It will be declared as " \
                       "requested after the next broker restart."
                }
              }, self.options[:context])
              { passive: true }
            ensure
              scratch.close if scratch.open?
            end
          end

          # Forgets the current channel, which a channel-level error left
          # closed, so that `channel` opens a fresh one.
          def renew_channel!
            Thread.current[CHANNEL_KEY] = nil
            channel
          end

          def consumer_pool_size
            options[:consumer_pool_size]
          end

          def abort_on_exception?
            options[:abort_on_exception]
          end

          def fanout_options
            options[:fanout_options]
          end

          def queue_options
            options[:queue_options]
          end

          def factor_event(body)
            if options[:event_factory]
              options[:event_factory].call(body)
            else
              Event.json(body, options)
            end
          end

        end # class Async
      end # module Bunny
    end # class Bus
  end # class Event
end # module Startback
