module Startback
  module Jobs
    class Agent < Startback::Event::Agent

      def install_listeners
        async Event::JobCreated, 'job-runner'
      end

      def call(event)
        run RunJob.new(event.data.to_h)
      end

    end # class Agent
  end # module Jobs
end # module Startback
