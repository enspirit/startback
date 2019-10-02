module StartbackTodo
  class CreateTodo < Operation

    def initialize(todo)
      @todo = todo
    end

    def call
      db.todos << @todo
    end

  end
end
