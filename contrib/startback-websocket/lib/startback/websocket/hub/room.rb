
module Startback
  module Websocket
    module Hub
      class Room < App

        def initialize(name)
          @name = name
          @participants = []
        end
        attr_reader :name, :participants

        def add(participant)
          raise "Participant instance expected" unless participant.is_a? Participant
          @participants << participant
          participant.socket.on :close do |event|
            remove(participant)
          end
        end

        def remove(participant)
          raise "Participant instance expected" unless participant.is_a? Participant
          @participants.delete participant
        end

        def include?(participant)
          raise "Participant instance expected" unless participant.is_a? Participant
          @participants.include? participant
        end

        def broadcast(message)
          puts "Broadcasting to #{@participants.size} participants"
          @participants.each do |p|
            p.socket.send({
              headers: {
                room: @name,
              },
              body: message
            }.to_json)
          end
        end

      end # class Room
    end # module Hub
  end # module Websocket
end # module Startback
