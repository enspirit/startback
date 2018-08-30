module Gyrb
  class Operation
    class ErrorOperation < Operation

      def initialize(details)
        @details = details
      end
      attr_reader :details

      def call
      end

      def bind(world)
        self
      end

    end # class ErrorOperation
  end # class Operation
end # module Gyrb
