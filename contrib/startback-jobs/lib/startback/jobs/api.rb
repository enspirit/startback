module Startback
  module Jobs
    class Api < Startback::Web::Api

      get %r{/([^\/]+)/result/?} do |id|
        job = context.factor(Services).get_job!(id: id)
        Support::JobResult.for(job).api_serve(self)
      end

    end # class Api
  end # module Jobs
end # module Startback
