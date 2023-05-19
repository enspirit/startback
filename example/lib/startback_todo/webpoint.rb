module StartbackTodo
  Webpoint = Rack::Builder.new do
    use Startback::Web::CatchAll
    use Startback::Web::Shield
    use Startback::Web::Prometheus

    use Startback::Context::Middleware, DEFAULT_CONTEXT
    use Startback::Audit::Middleware

    map '/errors' do
      run StartbackTodo::Errors
    end

    map '/api' do
      run StartbackTodo::Api
    end

    map '/health' do
      run Startback::Web::HealthCheck.new {
        "StartbackTodo v#{Startback::VERSION}"
      }
    end

    map '/' do
      use Rack::Static, :urls => ["/"], :root => 'public', :index => 'index.html'
      run ->(env) { [404, { 'Content-Type': 'text/plain' }, 'NotFound'] }
    end

  end.to_app
end
