
module Startback
  module Websocket
    #
    # Can be used to easily implement a custom websocket protocol inside a Startback
    # application.
    #
    # Please note that this rack app is not 100% Rack compliant, since it raises
    # any error that the block itself raises. This class aims at being backed up
    # by a Shield and/or CatchAll middleware.
    #
    class App

      JS_CLIENT = Path.dir/'../../../dist/client.js'

      def initialize(context)
        @context = context
        @context.websocket_app = self
        @connections = []
      end

      def call(env)
        request = Rack::Request.new(env)
        if Faye::WebSocket.websocket?(env)
          ws = factor_and_keep(env)
          ws.rack_response
        elsif request.path_info === '/client.js'
          [200, { 'Content-Type' => 'application/javascript' }, JS_CLIENT.readlines]
        else
          [400, { 'Content-Type' => 'text/plain' }, ['Websocket only!']]
        end
      end

      def broadcast(data)
        data = data.to_json unless data.is_a?(String)

        @connections.each do |socket|
          socket.send(data)
        end
      end

      def on_open(event, ws, env)
      end

      def on_close(event, ws, env)
      end

      def on_error(event, ws, env)
      end

      def on_message(event, ws, env)
      end

    private

      def factor_and_keep(env)
        ws = Faye::WebSocket.new(env)

        ws.on :open do |event|
          @connections << ws
          on_open(event, ws, env)
        end

        ws.on :close do |event|
          @connections.delete(ws)
          on_close(event, ws, env)
        end

        ws.on :message do |event|
          on_message(event, ws, env)
        end

        ws.on :error do |event|
          on_error(event, ws, env)
        end

        ws
      end

    end # class App
  end # module Websocket
end # module Startback
