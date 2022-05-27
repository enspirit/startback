module Startback
  module Jobs
    class Services < Startback::Services

      def get_job!(ref)
        job_relvar = startback_jobs.restrict(ref)
        Model::Job.full(job_relvar.one)
      rescue Bmg::OneError
        not_found_error!("Job #{ref[:id]}")
      end

      def update_job!(ref, update)
        job_relvar = startback_jobs.restrict(ref)
        job_relvar.update(update)
      end

    private

      def startback_jobs
        context.world.startback_jobs
      end

    end # class Services
  end # module Jobs
end # module Startback
