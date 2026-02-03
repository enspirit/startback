module Startback
  class Operation

    def self.emits(type, &bl)
      after_call do
        if event_data = instance_exec(&bl)
          event = type.new(type.to_s, event_data, context)
          context.engine.bus.emit(event)
        end
      end
    end

    def self.emits_on_commit(type, &bl)
      after_commit do
        if event_data = instance_exec(&bl)
          event = type.new(type.to_s, event_data, context)
          context.engine.bus.emit(event)
        end
      end
    end

  end # class Operation
end # module Startback
