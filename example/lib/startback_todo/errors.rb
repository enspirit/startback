module StartbackTodo
  class Errors < Startback::Web::Api

    get '/user-error' do
      raise Startback::BadRequestError
    end

    get '/specific-user-error' do
      raise Startback::BadRequestError, "Your request is wrong"
    end

    get '/gone-error' do
      raise Startback::GoneError
    end

    get '/internal-server-error' do
      raise Startback::InternalServerError
    end

  end # class Errors
end # module StartbackTodo
