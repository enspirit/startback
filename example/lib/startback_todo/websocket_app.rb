module StartbackTodo
  WebsocketApp = Startback::Websocket::Hub::Builder.new(DEFAULT_CONTEXT) do

    room 'notifications' do |room|
      command :subscribe do |cmd, socket, env|
        puts "Someone is subscribing to notifs"
        context = Startback::Context::Middleware.context(env)
        room.add Startback::Websocket::Hub::Participant.new(socket, context)
        cmd.reply success: true
      end
    end

  end.to_websocket_app
end # module StartbackTodo
