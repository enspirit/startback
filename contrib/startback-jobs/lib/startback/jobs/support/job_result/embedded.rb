module Startback
  module Jobs
    module Support
      class JobResult
        class Embedded < JobResult

          # Non HTTP-standard special success code to
          # indicate a job failure...
          FAILURE_STATUS_CODE = 272

          def api_serve(api)
            if job.failed?
              payload = job.opResult.delete_if{|k| k == :backtrace }
              [
                FAILURE_STATUS_CODE,
                {"Content-Type" => "application/json"},
                [payload.to_json]
              ]
            else
              [
                200,
                {"Content-Type" => "application/json"},
                [job.opResult.to_json]
              ]
            end
          end

        end # class Embedded
      end # class JobResult
    end # module Support
  end # module Jobs
end # module Startback
