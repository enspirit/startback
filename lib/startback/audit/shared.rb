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

    end # module Shared
  end # module Audit
end # module Startback
