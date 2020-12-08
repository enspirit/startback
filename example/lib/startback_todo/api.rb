module StartbackTodo
  class Api < Startback::Web::Api

    get '/todos/' do
      serve "Todos", db.todos
    end

    get '/todos/:id' do |id|
      todo = db.todos.restrict(id: Integer(id)).one_or_nil
      serve "Todo", todo
    end

    post '/todos/' do
      todo = json_body
      run CreateTodo.new(todo)
      status 201
      serve "Toto", todo
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

    around_run(PROMETHEUS)

  end # class Api
end # module StartbackTodo
