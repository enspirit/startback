module StartbackTodo
  App = Rack::Builder.new do
    use Startback::Web::CatchAll
    use Startback::Web::Shield

    map '/errors' do
      run StartbackTodo::Errors
    end

    run Startback::Web::HealthCheck.new {
      "StartbackTodo v#{Startback::VERSION}"
    }
  end
end
