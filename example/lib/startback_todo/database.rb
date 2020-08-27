module StartbackTodo
  class Database

    def initialize
      @todos ||= [
        { id: 1, description: "Write more code" }
      ]
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

  end
end
