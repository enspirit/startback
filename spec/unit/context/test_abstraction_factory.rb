require 'spec_helper'

module Startback
  describe Context do

    let(:context) {
      Context.new
    }

    class ContextRelatedAbstraction

      def initialize(context)
        @context = context
      end
      attr_reader :context

    end

    class ContextRelatedAbstractionWithArgs

      def initialize(arg1, arg2, context)
        @arg1 = arg1
        @arg2 = arg2
        @context = context
      end
      attr_reader :arg1, :arg2, :context

    end

    it 'is a factory for other context-related abstractions' do
      got = context.factor(ContextRelatedAbstraction)
      expect(got).to be_a(ContextRelatedAbstraction)
      expect(got.context).to be(context)

      got2 = context.factor(ContextRelatedAbstraction)
      expect(got2).to be(got)
    end

    it 'is takes cares of abstraction arguments' do
      got = context.factor(ContextRelatedAbstractionWithArgs, 12, 14)
      expect(got).to be_a(ContextRelatedAbstractionWithArgs)
      expect(got.context).to be(context)
      expect(got.arg1).to eql(12)
      expect(got.arg2).to eql(14)
    end

    it 'is caches even in presence ofabstraction arguments' do
      got = context.factor(ContextRelatedAbstractionWithArgs, 12, 14)
      expect(got).to be_a(ContextRelatedAbstractionWithArgs)

      got2 = context.factor(ContextRelatedAbstractionWithArgs, 12, 14)
      expect(got2).to be(got)
    end

    it 'is distinguishes different abstraction arguments' do
      got = context.factor(ContextRelatedAbstractionWithArgs, 12, 14)
      expect(got).to be_a(ContextRelatedAbstractionWithArgs)

      got2 = context.factor(ContextRelatedAbstractionWithArgs, 17, 14)
      expect(got2).not_to be(got)
    end

  end
end