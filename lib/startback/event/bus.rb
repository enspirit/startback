module Startback
  class Event
    #
    # Sync and async bus abstraction allowing to register listeners and
    # emitting events towards them.
    #
    # This bus actually decorates two busses, one in synchronous and the
    # other one is asynchronous (optional).
    #
    # * A synchronous bus MUST call the listeners as part of emitting
    #   process, and MUST re-raise any error occuring during that process.
    #   See, e.g. Startback::Bus::Memory::Sync
    #
    # * An asynchronous bus MAY call the listeners later, but MUST hide
    #   errors to the emitter.
    #   See, e.g. Startback::Bus::Memory::Async
    #
    # This bus facade emits events to both sync and async busses (if any),
    # and listen on the sync one by default.
    #
    # For emitters:
    #
    #     # This will synchronously call every listeners who `listen`
    #     # on the synchronous bus (& reraise exceptions) then call
    #     # (possibly later) all listeners who `listen` on the
    #     # asynchronous bus if any (& hide exceptions).
    #     bus.emit(event)
    #
    #     # This only reaches sync listeners
    #     bus.sync.emit(event)
    #
    #     # This only reaches async listeners (an async bus must be set)
    #     bus.async.emit(event)
    #
    # Please note that there is currently no way to reach sync listeners
    # without having to implement error handling on the emitter side.
    #
    # For listeners:
    #
    #     # This will listen synchronously and make the emitter fail if
    #     # anything goes wrong with the callback:
    #     bus.listen(event_type) do |event|
    #       ...
    #     end
    #
    #     # It is a shortcut for:
    #     bus.sync.listen(event_type) do |event| ... end
    #
    #     This will listen asynchronously and could not make the emitter
    #     fail if something goes wrong with the callback.
    #     bus.async.listen(event_type) do |event|
    #       ...
    #     end
    #
    # Feel free to access the sync and async busses directly for specific
    # cases though.
    #
    class Bus
      include Support::Robustness

      def initialize(sync = Memory::Sync.new, async = nil)
        @sync = sync
        @async = async
      end
      attr_reader :sync, :async

      def connect
        sync.connect if sync
        async.connect if async
      end

      def connected?
        if sync && async
          sync.connected? && async.connected?
        elsif sync
          sync.connected?
        elsif async
          async.connected?
        end
      end

      # Emits a particular event to the listeners.
      #
      # @arg event an event, should be an Event instance (through duck
      #      typing is allowed)
      def emit(event)
        monitor({
          op: "Startback::Bus#emit",
          op_data: {
            event: { type: event.type }
          }
        }, event.context) do
          sync.emit(event)
          async.emit(event) if async
        end
      end

      # Registers `listener` as being interested in receiving events of
      # a specific type.
      #
      # @arg type: Symbol, the type of event the listener is interested in.
      # @arg listener: Proc, the listener itself.
      def listen(type, processor = nil, listener = nil, &bl)
        sync.listen(type, processor, listener, &bl)
      end

    end # class Bus
  end # class Event
end # module Startback
require_relative 'bus/memory'
