module Startback
  class Event
    class Bus
      module Memory
        #
        # Synchronous implementation of the Bus abstraction, for use between
        # components sharing the same process.
        #
        class Sync
          include Support::Robustness

          def initialize
            @listeners = {}
          end

          def connect
          end

          def connected?
            true
          end

          def emit(event)
            (@listeners[event.type.to_s] || []).each do |l|
              l.call(event)
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
  end # class Event
end # module Startback
