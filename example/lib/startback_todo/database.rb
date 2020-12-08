module StartbackTodo
  class Database

    def initialize
      reset
    end

    def todos
      Model::Todos.new Bmg::Relation.new(@todos)
    end

    def insert_todo(todo)
      @todos << todo.to_h
    end

    def transaction
      yield
    end

    def reset
      @todos = [
        { id: 1, description: "Write more code" }
      ]
    end

  end
end
