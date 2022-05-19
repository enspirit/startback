require 'spec_helper'

module Startback
  describe Event do

    subject{
      Event.new("User::Changed", { "foo" => "bar" })
    }

    it 'presents an ostruct on top of its data' do
      expect(subject.data.foo).to eql("bar")
    end

    describe "the json information contract" do

      JSON_SRC = <<-JSON.gsub(/\s+/, "")
        {
          "type": "User::Changed",
          "data": {
            "foo": "bar"
          }
        }
      JSON

      it 'has a to_json method that works as expected' do
        expect(subject.to_json).to eql(JSON_SRC)
      end

      it 'has a to_json that dumps the context if any' do
        evt = Event.new("User::Changed", { "foo" => "bar" }, { "baz": "context" })
        expect(evt.to_json).to eql(<<-JSON.gsub(/\s+/, ""))
          {
            "type": "User::Changed",
            "data": {
              "foo": "bar"
            },
            "context": {
              "baz": "context"
            }
          }
        JSON
      end


      it 'has a json class method that works as expected' do
        evt = Event.json(JSON_SRC, nil)
        expect(evt).to be_a(Event)
        expect(evt.type).to eql("User::Changed")
        expect(evt.data).to eql(subject.data)
      end

      it 'accepts an explicit context as second argument' do
        evt = Event.json(JSON_SRC, 12)
        expect(evt.context).to eql(12)
      end
    end

  end
end # module Startback
