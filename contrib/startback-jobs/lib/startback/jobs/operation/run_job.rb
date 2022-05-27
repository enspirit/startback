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

        op_result = with_context(job_context) do
          run job_class.new(job_input)
        end

        services.update_job!(input, {
          opResult: op_result,
          isReady: true,
        })

        op_result
      end

      emits(Event::JobRan) do
        { id: @job.id }
      end

    end # class RunJob
  end # module Jobs
end # module Startback
