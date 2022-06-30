module Startback
  module Jobs
    module Support
      class JobResult

        def initialize(job)
          @job = job
        end
        private :initialize

        attr_reader :job

        def self.for(job)
          if job.is_ready?
            JobResult.const_get(job.strategy).new(job)
          else
            JobResult::NotReady.new(job)
          end
        end

        def api_serve(api)
          raise NotImplementedError
        end

      end # class JobResult
    end # module Support
  end # module Jobs
end # module Startback
require_relative 'job_result/not_ready'
require_relative 'job_result/embedded'
require_relative 'job_result/redirect'
