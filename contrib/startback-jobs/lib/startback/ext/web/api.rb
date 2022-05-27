module Startback
  module Web
    class Api

      def serve_job(job)
        job.result.api_serve(self)
      end
      protected :serve_job

    end # class Api
  end # module Web
end # module Startback
