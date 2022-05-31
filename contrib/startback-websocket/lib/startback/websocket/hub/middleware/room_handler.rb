
module Startback
  module Websocket
    module Hub
      module Middleware
        class RoomHandler

          def initialize(app, room, handler)
            @app = app
            @room = room
            @handler = handler
          end

          def call(event, socket, env)
            who = matches?(event) ? @handler : @app
            who.call(event, socket, env)
          end

          private

          def matches?(event)
            event.headers[:room] === @room.name
          end

        end # class RoomHandler
      end # module Middleware
    end # module Hub
  end # module Websocket
end # module Startback

