module Startback
  class Operation
    class MultiOperation < Operation

      def initialize(ops = [])
        @ops = ops
      end
      attr_reader :ops

      def size
        ops.size
      end

      def +(other)
        MultiOperation.new(@ops + Array(other))
      end

      def bind(world)
        MultiOperation.new(ops.map{|op| op.bind(world) })
      end

      def call
        ops.map{|op| op.call }
      end

    end # class MultiOperation
  end # class Operation
end # module Startback
