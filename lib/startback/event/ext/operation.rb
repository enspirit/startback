module Startback
  class Operation

    def self.emits(type, &bl)
      after_call do
        event_data = instance_exec(&bl)
        event = type.new(type.to_s, event_data, context)
        context.engine.bus.emit(event)
      end
    end

  end # class Operation
end # module Startback
