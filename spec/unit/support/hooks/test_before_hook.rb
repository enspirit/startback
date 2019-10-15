require 'spec_helper'
require 'singleton'
module Startback
  module Support
    describe Hooks, "before_xxx" do

      class BeforeHooked
        include Hooks.new(:xxx)

        def initialize
          super
          @before_called = false
        end
        attr_accessor :before_called

        before_xxx do
          self.before_called = true
        end

      end

      class SubBeforeHooked < BeforeHooked

        def initialize
          super
          @subbefore_called = false
        end
        attr_accessor :subbefore_called

        before_xxx do
          self.subbefore_called = true
        end

      end

      it 'works as expected' do
        h = BeforeHooked.new
        expect(h.before_called).to eql(false)
        h.before_xxx
        expect(h.before_called).to eql(true)
      end

      it 'works as expected on subclass' do
        h = SubBeforeHooked.new
        expect(h.before_called).to eql(false)
        expect(h.subbefore_called).to eql(false)
        h.before_xxx
        expect(h.before_called).to eql(true)
        expect(h.subbefore_called).to eql(true)
      end

    end
  end
end