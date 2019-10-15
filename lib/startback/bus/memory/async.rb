module Startback
  class Bus
    module Memory
      #
      # Asynchronous implementation of the Bus abstraction, for use between
      # components sharing the same process.
      #
      # This implementation actually calls listeners synchronously (it mays)
      # but hides error raised by them. See Bus::Bunny::Async for another
      # implementation that is truly asynchronous and relies on RabbitMQ.
      #
      class Async
        include Bus::Helpers

        DEFAULT_OPTIONS = {
        }

        def initialize(options = {})
          @options = DEFAULT_OPTIONS.merge(options)
          @listeners = {}
        end

        def emit(event)
          (@listeners[event.type.to_s] || []).each do |l|
            with_error_handling {
              l.call(event)
            }
          end
        end

        def listen(type, processor = nil, listener = nil, &bl)
          raise ArgumentError, "A listener must be provided" unless listener || bl
          @listeners[type.to_s] ||= []
          @listeners[type.to_s] << (listener || bl)
        end

      end # class Sync
    end # module Memory
  end # class Bus
end # module Klaro
