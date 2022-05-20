require 'spec_helper'

module Startback
  describe Context, "dup" do

    let(:context) {
      SubContext.new.tap{|s| s.foo = "bar" }
    }

    class ContextRelatedAbstraction

      def initialize(context)
        @context = context
      end
      attr_reader :context

    end

    it 'yields a dup of the original context' do
      seen = false
      got = context.dup{|x|
        seen = x
        expect(x).not_to be(context)
      }
      expect(seen).to be(got)
      expect(got).to be_a(SubContext)
      expect(got).not_to be(context)
      expect(got.foo).to eql("bar")
    end

    it 'cleans all factored cache' do
      cra = context.factor(ContextRelatedAbstraction)
      expect(cra).to be_a(ContextRelatedAbstraction)
      cra2 = context.factor(ContextRelatedAbstraction)
      expect(cra2).to be(cra)
      cra3 = context.dup.factor(ContextRelatedAbstraction)
      expect(cra3).not_to be(cra)
      expect(cra3).not_to be(cra2)
    end

  end
end
