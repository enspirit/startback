require 'spec_helper'
require 'startback/event/bus/bunny'

module Startback
  class Event
    describe Bus::Bunny::Async do

      # Exchange and queue names are per-example, see BunnyBroker#unique:
      # both are durable, so they outlive the example that created them.
      let(:type)      { BunnyBroker.unique("Spec::Event") }
      let(:processor) { BunnyBroker.unique("spec-processor") }
      let(:url)       { BunnyBroker.url }

      let(:bus) { Bus::Bunny::Async.new(url) }

      # Busses an example connected, closed afterwards whatever happens, so
      # that a failing example does not leak a connection into the next one.
      let(:opened) { [] }

      def connected_bus(options = {})
        Bus::Bunny::Async.new({ url: url }.merge(options)).tap do |b|
          opened << b
          b.connect unless options[:autoconnect]
        end
      end

      before do
        BunnyBroker.skip_unless_available!(self)
      end

      after do
        opened.each { |b| b.disconnect rescue nil }
        BunnyBroker.delete_topology(exchanges: [type], queues: [processor, "main"])
      end

      describe "connecting" do

        it 'is not connected before connect is called' do
          expect(bus.connected?).to be_falsey
        end

        it 'connects and disconnects' do
          b = connected_bus
          expect(b.connected?).to eql(true)
          b.disconnect
          expect(b.connected?).to be_falsey
        end

        it 'connects at construction when autoconnect is set' do
          b = connected_bus(autoconnect: true)
          expect(b.connected?).to eql(true)
        end

        it 'takes a String as being the url' do
          b = Bus::Bunny::Async.new(url)
          opened << b
          expect(b.options[:url]).to eql(url)
          b.connect
          expect(b.connected?).to eql(true)
        end

        it 'defaults the url to STARTBACK_BUS_BUNNY_ASYNC_URL' do
          # DEFAULT_OPTIONS captures the variable at load time, so the class
          # constant is the observable, not a re-read of ENV here.
          expect(Bus::Bunny::Async::DEFAULT_OPTIONS[:url])
            .to eql(ENV['STARTBACK_BUS_BUNNY_ASYNC_URL'])
        end

        it 'refuses to hand out a channel before connecting' do
          expect {
            bus.channel
          }.to raise_error(Startback::Errors::Error, /connect your bus first/)
        end

      end

      describe "emitting and listening" do

        it 'round trips an event through the broker with default options' do
          # Regression test for the defaults themselves: RabbitMQ 4 refuses
          # transient non-exclusive queues, which is what queue_options used
          # to ask for. This example fails with a Timeout::Error there.
          b = connected_bus
          seen = Queue.new
          b.listen(type, processor) { |body| seen << body }
          b.emit(Event.new(type, { id: 12 }))

          received = BunnyBroker.wait_for { seen.pop unless seen.empty? }
          expect(received).not_to be_nil
          parsed = JSON.parse(received)
          expect(parsed["type"]).to eql(type)
          expect(parsed["data"]).to eql({ "id" => 12 })
        end

        it 'hands the listener the raw JSON String, not an Event' do
          # Documents an asymmetry with Bus::Memory::Async, which hands over
          # an Event instance. Listeners are not portable between the two.
          b = connected_bus
          seen = Queue.new
          b.listen(type, processor) { |body| seen << body }
          b.emit(Event.new(type, { id: 12 }))

          received = BunnyBroker.wait_for { seen.pop unless seen.empty? }
          expect(received).to be_a(String)
        end

        it 'declares the exchange and the queue durable' do
          b = connected_bus
          b.listen(type, processor) { |body| }

          # Redeclaring passively tells us what the broker actually holds:
          # a mismatch on durable would raise Bunny::PreconditionFailed.
          expect {
            ch = b.channel
            ch.fanout(type, durable: true, passive: true)
            ch.queue(processor, durable: true, passive: true)
          }.not_to raise_error
        end

        it 'allows mixing Symbol vs. String for event type' do
          b = connected_bus
          seen = Queue.new
          b.listen(type.to_sym, processor) { |body| seen << body }
          b.emit(Event.new(type.to_sym, { id: 12 }))

          received = BunnyBroker.wait_for { seen.pop unless seen.empty? }
          expect(received).not_to be_nil
          expect(JSON.parse(received)["type"]).to eql(type)
        end

        it 'fans an event out to every processor queue' do
          other = BunnyBroker.unique("spec-other")
          b = connected_bus
          one, two = Queue.new, Queue.new
          b.listen(type, processor) { |body| one << body }
          b.listen(type, other)     { |body| two << body }
          b.emit(Event.new(type, { id: 12 }))

          expect(BunnyBroker.wait_for { one.pop unless one.empty? }).not_to be_nil
          expect(BunnyBroker.wait_for { two.pop unless two.empty? }).not_to be_nil

          BunnyBroker.delete_topology(queues: [other])
        end

        it 'does not deliver an event to a queue bound to another type' do
          other_type = BunnyBroker.unique("Spec::Other")
          b = connected_bus
          seen = Queue.new
          b.listen(other_type, processor) { |body| seen << body }
          b.emit(Event.new(type, { id: 12 }))

          # Nothing should arrive. Give the broker a real chance to prove us
          # wrong before concluding, hence a short but non-zero wait.
          expect(BunnyBroker.wait_for(1) { seen.pop unless seen.empty? }).to be_nil

          BunnyBroker.delete_topology(exchanges: [other_type])
        end

        it 'requires a listener' do
          b = connected_bus
          expect {
            b.listen(type, processor)
          }.to raise_error(ArgumentError, /listener must be provided/)
        end

      end

      describe "adopting a pre-existing topology" do

        # What an older Startback left on the broker: a transient exchange.
        # This is the upgrade path, and it must not need a broker-side
        # migration. Only the exchange, because a transient queue cannot be
        # declared at all from RabbitMQ 4.3 on -- see the last example here.
        def declare_legacy_exchange!
          conn = ::Bunny.new(url, log_level: :fatal)
          conn.start
          conn.create_channel.fanout(type, {})
          conn.close
        end

        it 'emits through a transient exchange instead of dropping the event' do
          declare_legacy_exchange!
          b = connected_bus

          seen = Queue.new
          b.listen(type, processor) { |body| seen << body }
          b.emit(Event.new(type, { id: 12 }))

          received = BunnyBroker.wait_for { seen.pop unless seen.empty? }
          expect(received).not_to be_nil
          expect(JSON.parse(received)["data"]).to eql({ "id" => 12 })
        end

        it 'leaves the adopted exchange alone rather than redeclaring it' do
          declare_legacy_exchange!
          b = connected_bus
          b.listen(type, processor) { |body| }

          # Still transient: adopting means taking what is there. Declaring
          # it transient again would raise had the bus turned it durable.
          conn = ::Bunny.new(url, log_level: :fatal)
          conn.start
          expect {
            conn.create_channel.fanout(type, durable: false)
          }.not_to raise_error
          conn.close
        end

        it 'keeps the channel usable after the conflict' do
          # The conflict closes the channel. Before the bus learned to renew
          # it, the closed one stayed cached per thread and every later emit
          # failed with "cannot use a closed channel" -- silently, since
          # `emit` runs inside stop_errors -- whatever the event type.
          declare_legacy_exchange!
          b = connected_bus
          b.emit(Event.new(type, { id: 1 }))

          expect(b.channel.open?).to eql(true)

          other_type = BunnyBroker.unique("Spec::Unrelated")
          other_proc = BunnyBroker.unique("spec-unrelated")
          seen = Queue.new
          b.listen(other_type, other_proc) { |body| seen << body }
          b.emit(Event.new(other_type, { id: 2 }))

          received = BunnyBroker.wait_for { seen.pop unless seen.empty? }
          expect(received).not_to be_nil

          BunnyBroker.delete_topology(exchanges: [other_type], queues: [other_proc])
        end

        it 'keeps delivering when exchange AND queue were both transient' do
          # The true state an older Startback leaves behind, and the one that
          # matters: adopting two objects means two channel renewals, so the
          # consumer ends up on a different channel than the one the exchange
          # was adopted on. Probing on the shared channel would then have
          # `emit` close the consumer's channel -- events silently lost.
          #
          # Only reproducible where transient queues can still be declared,
          # i.e. RabbitMQ <= 4.2, which is why CI runs a broker of that
          # generation alongside the current one.
          BunnyBroker.skip_unless_transient_queues!(self)

          conn = ::Bunny.new(url, log_level: :fatal)
          conn.start
          ch = conn.create_channel
          ch.queue(processor, {}).bind(ch.fanout(type, {}))
          conn.close

          b = connected_bus
          seen = Queue.new
          b.listen(type, processor) { |body| seen << body }
          b.emit(Event.new(type, { id: 12 }))

          received = BunnyBroker.wait_for { seen.pop unless seen.empty? }
          expect(received).not_to be_nil
          expect(JSON.parse(received)["data"]).to eql({ "id" => 12 })
        end

      end

      describe "the asynchronous contract" do

        it 'hides emit errors from the emitter' do
          # An async bus MUST NOT let errors reach the emitter. Emitting
          # without connecting raises inside, and must stay inside.
          expect {
            bus.emit(Event.new(type, { id: 12 }))
          }.not_to raise_error
        end

        it 'keeps consuming after a listener raised' do
          b = connected_bus
          seen = Queue.new
          calls = Queue.new
          b.listen(type, processor) do |body|
            calls << body
            raise "listener blew up" if JSON.parse(body)["data"]["id"] == 1

            seen << body
          end

          b.emit(Event.new(type, { id: 1 }))
          expect(BunnyBroker.wait_for { calls.pop unless calls.empty? }).not_to be_nil

          b.emit(Event.new(type, { id: 2 }))
          received = BunnyBroker.wait_for { seen.pop unless seen.empty? }
          expect(received).not_to be_nil
          expect(JSON.parse(received)["data"]).to eql({ "id" => 2 })
        end

      end

    end
  end
end
