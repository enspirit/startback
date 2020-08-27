module StartbackTodo
  module Model
    class Todo < OpenStruct

      def to_json(*args, &bl)
        to_h.to_json(*args, &bl)
      end

    end
  end
end
