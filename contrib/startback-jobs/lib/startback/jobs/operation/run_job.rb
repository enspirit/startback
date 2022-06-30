module Startback
  module Jobs
    class RunJob < Operation

      def initialize(input)
        super(System['Job.Ref'].dress(input))
      end

      def call
        services = context.factor(Services)
        @job = services.get_job!(input)

        job_context = context.fork(@job.op_context)
        job_class = ::Kernel.const_get(@job.op_class)
        job_input = @job.op_input

        has_failed, op_result = with_context(job_context) do
          op_result = run job_class.new(job_input)
          [false, op_result]
        rescue => err
          [true, error_to_result(err) ]
        end

        services.update_job!(input, {
          opResult: op_result,
          hasFailed: has_failed,
          isReady: true,
          strategy: 'Embedded',
        })

        op_result
      end

      def error_to_result(err)
        {
          errClass: err.class.name.to_s,
          message: err.message,
          backtrace: err.backtrace
        }
      end

      emits(Event::JobRan) do
        { id: @job.id }
      end

    end # class RunJob
  end # module Jobs
end # module Startback
