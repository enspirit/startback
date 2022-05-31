
module Startback
  module Websocket
    module Hub
      module Middleware
        class CommandHandler

          def initialize(app, opts, &bl)
            @app = app
            @opts = opts
            @handler = bl
          end

          def call(event, socket, env)
            who = matches?(event) ? @handler : @app
            who.call(event, socket, env)
          end

        private

          def matches?(event)
            if event.headers[:command]
              event.headers[:command]&.to_sym === @opts[:name]
            else
              false
            end
          end

        end # class CommandHandler
      end # module Middleware
    end # module Hub
  end # module Websocket
end # module Startback

