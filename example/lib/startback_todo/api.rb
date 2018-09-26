module StartbackTodo
  class Api < Startback::Web::Api

    get '/todos/' do
      serve "Todos", [
        {id: 1, description: "Write more code"}
      ]
    end

  end # class Api
end # module StartbackTodo
