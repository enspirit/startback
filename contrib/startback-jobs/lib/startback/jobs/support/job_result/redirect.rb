module Startback
  module Jobs
    module Support
      class JobResult
        class Redirect < JobResult

          DEFAULT_REDIRECT_OPTIONS = {
            status: 301,
            headers: {}
          }.freeze

          def api_serve(api)
            options = redirect_options
            [
              options.status || 301,
              options.headers.merge("Location" => job.opResult),
              []
            ]
          end

          def redirect_options
            opts = DEFAULT_REDIRECT_OPTIONS.merge(
              job.strategy_options
            )
            Startback::Model.new(opts)
          end

        end # class Embedded
      end # class JobResult
    end # module Support
  end # module Jobs
end # module Startback
