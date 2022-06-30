module Startback
  module Jobs
    class CreateJob < Operation

      def initialize(input)
        super(System['Job.CreationRequest'].dress(input))
      end

      def call
        @job = Model::Job.full({
          id: SecureRandom.urlsafe_base64(16),
          opInput: {},
          opContext: {},
          opResult: nil,
          strategy: 'NotReady',
          strategyOptions: {},
          expiresAt: nil,
          hasFailed: false,
          refreshFreq: nil,
          refreshedAt: nil,
          consumeMax: nil,
          consumeCount: 0,
          createdAt: Time.now,
          createdBy: nil,
        }.merge(input))

        context.world.startback_jobs.insert(@job.to_data)

        @job
      end

      emits(Event::JobCreated) do
        { id: @job.id }
      end

    end # class CreateJob
  end # module Jobs
end # module Startback
