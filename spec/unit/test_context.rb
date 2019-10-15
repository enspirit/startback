require 'spec_helper'

module Startback
  describe Context do

    it "has a to_json that dumps it" do
      expect(Context.new.to_json).to eql("{}")
    end

    class SubContext < Context
      attr_accessor :foo
      h_factory do |c,h|
        c.foo = h["foo"]
      end
      h_dump do |h|
        h.merge!("foo" => foo)
      end
    end
 
    class SubContext
      attr_accessor :bar
      h_factory do |c,h|
        c.bar = h["bar"]
      end
      h_dump do |h|
        h.merge!("bar" => bar)
      end
    end

    it 'allows installing factories' do
      expect(Context.h_factories).to be_empty
      expect(SubContext.h_factories.size).to eql(2)
    end

    it 'has a `to_h` information contract that works as expected' do
      context = SubContext.new.tap{|c|
        c.foo = "Hello"
        c.bar = "World"
      }
      expect(context.to_h).to eql({ "foo" => "Hello", "bar" => "World" })
    end

    it 'has a `h` information contract that works as expected' do
      context = SubContext.h({ "foo" => "Hello", "bar" => "World" })
      expect(context).to be_a(SubContext)
      expect(context.foo).to eql("Hello")
      expect(context.bar).to eql("World")
    end

  end
end
