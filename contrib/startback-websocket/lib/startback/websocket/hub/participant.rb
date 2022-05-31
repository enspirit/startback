module Startback
  module Websocket
    module Hub
      class Participant

        def initialize(socket, context, metadata={})
          @socket = socket
          @context = context
          @metadata = metadata
        end
        attr_reader :socket, :context, :metadata

      end # class Participant
    end # module Hub
  end # module Websocket
end # module Startback
