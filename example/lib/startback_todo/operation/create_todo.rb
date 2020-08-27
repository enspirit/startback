module StartbackTodo
  class CreateTodo < Operation

    def initialize(todo)
      @todo = todo
    end

    def call
      db.insert_todo(@todo)
    end

  end
end
