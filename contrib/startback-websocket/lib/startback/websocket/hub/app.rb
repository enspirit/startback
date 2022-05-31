
module Startback
  module Websocket
    module Hub
      #
      # The Hub is a very opinionated websocket protocol based on room and
      # subscriptions, allowing users to subscribe to rooms etc etc... # TODO
      #
      class App < Websocket::App

        def initialize(context, rooms, handler)
          super(context)
          @handler = handler
          @rooms = rooms
        end

        def room(name)
          @rooms[name]
        end

        def on_message(event, ws, env)
          @handler.call(Message.new(event.data, ws), ws, env)
        end

      end # class App
    end # module Hub
  end # module Websocket
end # module Startback
