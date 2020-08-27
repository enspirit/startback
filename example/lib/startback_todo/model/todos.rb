module StartbackTodo
  module Model
    class Todos

      def initialize(todos)
        @todos = todos
      end
      attr_reader :todos

      def restrict(*args, &bl)
        Todos.new(todos.restrict(*args, &bl))
      end

      def one_or_nil(*args, &bl)
        todos.one_or_nil(*args, &bl)
      end

      def to_a
        todos.to_a
      end

      def to_dto(context)
        Dto::Todos.new(self, context)
      end

      def to_json(*args, &bl)
        todos.to_json(*args, &bl)
      end

      def to_csv(*args, &bl)
        todos.to_csv(*args, &bl)
      end

    end
  end
end
