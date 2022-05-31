require 'spec_helper'
require 'startback/websocket'

module Startback
  module Websocket
    module Hub
      describe Room do

        context 'add' do

          room = Room.new('room-name')

          it 'expects participant instances' do
            expect { room.add SpecHelpers.MockSocket.new }.to raise_error
          end

          it 'allows adding participants to the room' do
            room.add Participant.new(SpecHelpers::MockSocket.new, SpecHelpers::SubContext.new)
            expect(room.participants.size).to eql(1)
          end

        end

      end # describe
    end # module Hub
  end # module Websocket
end # module Startback
