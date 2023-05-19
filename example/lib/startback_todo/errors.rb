module StartbackTodo
  class Errors < Startback::Web::Api

    class Op < Operation
      def initialize(clazz, message = nil)
        @clazz = clazz
        @message = message
      end

      def call
        raise @clazz, @message
      end
    end

    get '/user-error' do
      run Op.new(Startback::BadRequestError)
    end

    get '/not-found-error' do
      run Op.new(Startback::NotFoundError)
    end

    get '/specific-user-error' do
      run Op.new(Startback::BadRequestError, "Your request is wrong")
    end

    get '/gone-error' do
      run Op.new(Startback::GoneError)
    end

    get '/internal-server-error' do
      run Op.new(Startback::InternalServerError)
    end

    around_run(PROMETHEUS)
    around_run(OPERATION_TRACER)
  end # class Errors
end # module StartbackTodo
