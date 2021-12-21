module Startback
  module Support
    class TransactionManager

      def initialize(db, method = :transaction)
        @db = db
        @method = method
      end

      def call(runner, op, &then_block)
        raise ArgumentError, "A block is required" unless then_block

        before = (op.class.transaction_policy == :before_call)
        if before
          @db.send(@method) do
            then_block.call
          end
        else
          then_block.call
        end
      end

    end # class TransactionManager
  end # module Support
end # module Startback
