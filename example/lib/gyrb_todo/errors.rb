module GyrbTodo
  class Errors < Gyrb::Web::Api

    get '/user-error' do
      raise Gyrb::BadRequestError
    end

    get '/specific-user-error' do
      raise Gyrb::BadRequestError, "Your request is wrong"
    end

    get '/gone-error' do
      raise Gyrb::GoneError
    end

    get '/internal-server-error' do
      raise Gyrb::InternalServerError
    end

  end # class Errors
end # module GyrbTodo
