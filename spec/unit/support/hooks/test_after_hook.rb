require 'spec_helper'
require 'singleton'
module Startback
  module Support
    describe Hooks, "after_xxx" do

      class AfterHooked
        include Hooks.new(:xxx)

        def initialize
          super
          @after_called = false
        end
        attr_accessor :after_called

        after_xxx do
          self.after_called = true
        end

      end

      class SubAfterHooked < AfterHooked

        def initialize
          super
          @subafter_called = false
        end
        attr_accessor :subafter_called

        after_xxx do
          self.subafter_called = true
        end

      end

      it 'works as expected' do
        h = AfterHooked.new
        expect(h.after_called).to eql(false)
        h.after_xxx
        expect(h.after_called).to eql(true)
      end

      it 'works as expected on subclass' do
        h = SubAfterHooked.new
        expect(h.after_called).to eql(false)
        expect(h.subafter_called).to eql(false)
        h.after_xxx
        expect(h.after_called).to eql(true)
        expect(h.subafter_called).to eql(true)
      end

    end
  end
end