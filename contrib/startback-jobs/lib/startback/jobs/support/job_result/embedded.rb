module Startback
  module Jobs
    module Support
      class JobResult
        class Embedded < JobResult

          def api_serve(api)
            [
              200,
              {"Content-Type" => "application/json"},
              [job.opResult.to_json]
            ]
          end

        end # class Embedded
      end # class JobResult
    end # module Support
  end # module Jobs
end # module Startback
