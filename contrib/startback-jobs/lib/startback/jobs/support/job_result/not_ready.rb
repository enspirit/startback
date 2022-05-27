module Startback
  module Jobs
    module Support
      class JobResult
        class NotReady < JobResult

          def api_serve(api)
            [202, {}, []]
          end

        end # class NotReady
      end # class JobResult
    end # module Support
  end # module Jobs
end # module Startback
