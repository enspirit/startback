module Startback
  module Jobs
    module Support
      class JobResult
        class Embedded < JobResult

          def api_serve(api)
            [200, {}, [job.opResult]]
          end

        end # class Embedded
      end # class JobResult
    end # module Support
  end # module Jobs
end # module Startback
