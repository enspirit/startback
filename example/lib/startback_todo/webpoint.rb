module StartbackTodo
  Webpoint = Rack::Builder.new do
    use Startback::Web::CatchAll
    use Startback::Web::Shield
    use Startback::Web::Prometheus

    use Startback::Context::Middleware, DEFAULT_CONTEXT


    map '/errors' do
      run StartbackTodo::Errors
    end

    map '/api' do
      run StartbackTodo::Api
    end

    map '/ws' do
      builder = Startback::Websocket::Hub::Builder.new(DEFAULT_CONTEXT) do

        room 'notifications' do |room|
          command :subscribe do |cmd, socket|
            puts "Someone is subscribing to notifs"
            room.add(socket)
          end
        end

      end
      run builder.to_app
    end

    use Rack::Static, :urls => [""], :root => 'public', :index => 'index.html'

    map '/health' do
      run Startback::Web::HealthCheck.new {
        "StartbackTodo v#{Startback::VERSION}"
      }
    end

  end.to_app
end
