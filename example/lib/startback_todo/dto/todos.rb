module StartbackTodo
  module Dto
    class Todos

      def initialize(model, context)
        @model = model
        @context = context
      end
      attr_reader :model, :context

      def to(content_type, default = nil)
        case content_type ||= default || "application/json"
        when /application\/json/
          [content_type, model.to_json]
        when /text\/csv/
          [content_type, model.to_csv]
        else
          Startback::Errors.not_acceptable_error!(content_type)
        end
      end

    end
  end
end
