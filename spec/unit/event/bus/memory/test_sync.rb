require 'spec_helper'
module Startback
  class Event
    describe Bus::Memory do

      subject{
        Bus::Memory::Sync.new
      }

      it 'allows emiting an receiving' do
        seen = nil
        subject.listen("user_changed") do |evt|
          seen = evt
        end
        subject.emit(Event.new("user_changed", {id: 12}))
        expect(seen).to be_a(Event)
        expect(seen.type).to eql("user_changed")
        expect(seen.data.to_h).to eql({id: 12})
      end

      it 'allows mixin Symbol vs. String for event type' do
        seen = nil
        subject.listen(:user_changed) do |evt|
          seen = evt
        end
        subject.emit(Event.new(:user_changed, {id: 12}))
        expect(seen).to be_a(Event)
        expect(seen.type).to eql("user_changed")
        expect(seen.data.to_h).to eql({id: 12})
      end

      it 'raises emit errors synchronously' do
        subject.listen("user_changed") do |evt|
          raise "An error occured"
        end
        expect {
          subject.emit(Event.new("user_changed", {id: 12}))
        }.to raise_error("An error occured")
      end

    end
  end
end
