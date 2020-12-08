module StartbackTodo
  App = Rack::Builder.new do
    use Startback::Web::CatchAll
    use Startback::Web::Shield
    use Startback::Web::Prometheus

    use Startback::Context::Middleware

    map '/errors' do
      run StartbackTodo::Errors
    end

    map '/api' do
      run StartbackTodo::Api
    end

    run Startback::Web::HealthCheck.new {
      "StartbackTodo v#{Startback::VERSION}"
    }
  end
end
