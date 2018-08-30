module GyrbTodo
  App = Rack::Builder.new do
    use Gyrb::Web::CatchAll
    use Gyrb::Web::Shield

    map '/errors' do
      run GyrbTodo::Errors
    end

    run Gyrb::Web::HealthCheck.new {
      "GyrbTodo v#{Gyrb::VERSION}"
    }
  end
end
