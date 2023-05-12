require 'startback/audit'

module Startback
  module Audit
    class OperationTracer
      include Startback::Audit::Shared

      def call(runner, op, &block)
        op.context.trace_span({
          type: :operation,
          op: op_name(op),
          data: op_data(op),
          context: op_context(op)
        }, &block)
      end

    end # class OperationTracer
  end # module Audit
end # module Startback
