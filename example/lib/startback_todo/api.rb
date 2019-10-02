module StartbackTodo
  class Api < Startback::Web::Api

    get '/todos/' do
      serve "Todos", db.todos
    end

    post '/todos/' do
      todo = json_body
      run CreateTodo.new(todo)
      status 201
      content_type :json
      todo.to_json
    end

  private

    def db
      DB
    end

    around_run do |_,then_block|
      db.transaction(&then_block)
    end

    def operation_world(op)
      super(op).merge(db: db)
    end

  end # class Api
end # module StartbackTodo
