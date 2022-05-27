module Startback
  module Support
    module OperationRunner

      def run_as_job(op)
        run Startback::Jobs::CreateJob.new({
          isReady: false,
          opClass: op.class.name,
          opInput: op.input,
          opContext: context.to_h,
          createdBy: '',
        })
      end

    end # module OperationRunner
  end # module Support
end # module Startback
