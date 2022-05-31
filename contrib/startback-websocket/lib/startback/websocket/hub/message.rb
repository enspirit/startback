
module Startback
  module Websocket
    module Hub
      class Message

        def initialize(data, socket)
          data = JSON.parse(data, symbolize_names: true)
          @headers = data[:headers] || {}
          @body = data[:body] || {}
          @socket = socket
        end
        attr_reader :headers, :body, :socket

        def reply(message)
          raise "No reply-to header found" unless headers[:'reply-to']
          response = {
            headers: {
              :'in-reply-to' => headers[:'reply-to']
            },
            body: message
          }
          @socket.send(response.to_json)
        end

      end # class Message
    end # module Hub
  end # module Websocket
end # module Startback
