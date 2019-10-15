require 'spec_helper'

module Startback
  describe Operation do

    class FooOp < Operation

      def initialize(foo = :bar)
        @foo = foo
      end
      attr_accessor :foo

      def call
        @foo
      end

    end

    it 'can be bound, which returns a new operation' do
      foo1 = FooOp.new
      foo1.foo = :bar1

      foo2 = foo1.bind({ db: :bar })
      expect(foo2.foo).to eql(:bar1)
      expect(foo2.db).to eql(:bar)
    end

  end

  describe Operation::MultiOperation do

    it 'lets chain with +' do
      mop = Operation::MultiOperation.new
      mop2 = (mop + FooOp.new)

      expect(mop == mop2).to eql(false)
      expect(mop.size).to eql(0)
      expect(mop2.size).to eql(1)
    end

    it 'calls and collects the result on call' do
      mop = Operation::MultiOperation.new + FooOp.new(:hello) + FooOp.new(:world)
      expect(mop.call).to eql([:hello, :world])
    end

    it 'binds every sub operation recursively' do
      mop = Operation::MultiOperation.new + FooOp.new(:hello) + FooOp.new(:world)
      mop2 = mop.bind({requester: :bar})

      expect(mop == mop2).to eql(false)
      expect(mop2.ops.all?{|op| op.requester == :bar })        
    end

  end
end # module Startback
