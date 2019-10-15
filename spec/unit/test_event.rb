require 'spec_helper'

module Startback
  describe Event do

    subject{
      Event.new("user_changed", { "foo" => "bar" })
    }

    it 'presents an ostruct on top of its data' do
      expect(subject.data.foo).to eql("bar")
    end

    describe "the json information contract" do

      JSON_SRC = <<-JSON.gsub(/\s+/, "")
        {
          "type": "user_changed",
          "data": {
            "foo": "bar"
          }
        }
      JSON

      it 'has a to_json method that works as expected' do
        expect(subject.to_json).to eql(JSON_SRC)
      end

      it 'has a to_json that dumps the context if any' do
        evt = Event.new("user_changed", { "foo" => "bar" }, { "baz": "context" })
        expect(evt.to_json).to eql(<<-JSON.gsub(/\s+/, ""))
          {
            "type": "user_changed",
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
        evt = Event.json(JSON_SRC)
        expect(evt).to be_a(Event)
        expect(evt.type).to eql("user_changed")
        expect(evt.data).to eql(subject.data)
      end

      it 'accepts an explicit context in the world' do
        evt = Event.json(JSON_SRC, context: 12)
        expect(evt.context).to eql(12)
      end

      it 'accepts an context factory in the world' do
        cf = ->(arg) {
          expect(arg).to eql(JSON.parse(JSON_SRC))
          12
        }
        evt = Event.json(JSON_SRC, context_factory: cf)
        expect(evt.context).to eql(12)
      end

    end

  end
end # module Startback
