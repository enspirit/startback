module StartbackTodo
  class Agent < Startback::Event::Agent

    def install_listeners
      sync Event::TodoCreated, 'send-notification'
    end

    def call(event)
      event.context.websocket_app
        .room('notifications')
        .broadcast(event)
    end

  end
end
