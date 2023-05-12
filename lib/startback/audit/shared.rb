module Startback
  module Audit
    module Shared

      def op_name(op)
        return op.op_name if op.respond_to?(:op_name)

        case op
        when String then op
        when Class  then op.name
        else op.class.name
        end
      end

      def op_context(op)
        op.respond_to?(:context, false) ? op.context.to_h : {}
      end

      def op_data(op)
        if op.respond_to?(:op_data, false)
          op.op_data
        elsif op.respond_to?(:to_trail, false)
          op.to_trail
        elsif op.respond_to?(:input, false)
          op.input
        elsif op.respond_to?(:request, false)
          op.request
        elsif op.is_a?(Operation::MultiOperation)
          op.ops.map{ |sub_op| op_to_trail(sub_op) }
        end
      end

    end # module Shared
  end # module Audit
end # module Startback
