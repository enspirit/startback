module Startback
  module Support
    module TransactionPolicy

      # Returns the operation's transaction policy
      def transaction_policy
        @transaction_policy || :before_call
      end

      # Sets the transaction policy to use. Valid values are:
      # - before_call : the transaction is started by the operation
      #   runner, right before calling the #call method on operation
      #   instance
      # - within_call: the transaction is started by the operation
      #   itself, as part of its internal logic.
      def transaction_policy=(policy)
        unless [:before_call, :within_call].include?(policy)
          raise ArgumentError, "Unknown policy `#{policy}`"
        end
        @transaction_policy = policy
      end

      def after_commit(&bl)
        after_call do
          db.after_commit do
            instance_exec(&bl)
          end
        end
      end

    end # module TransactionPolicy
  end # module Support
end # module Startback
