module Startback
  module Jobs
    class Model
      class Job < Model
        def self.ref(data)
          dress(data, 'Job.Ref')
        end

        def self.full(data)
          dress(data, 'Job.Full')
        end

        def ready?
          self.isReady
        end

        def not_ready?
          !ready?
        end

        def failed?
          !!self[:hasFailed]
        end

        def succeeded?
          !failed?
        end

        def expired?
          self.expiredAt && self.expiredAt < Time.now
        end

        def fully_consumed?
          self.consumedMax && (self.consumedCount || 0 >= self.consumedMax)
        end

        def result
          Support::JobResult.for(self)
        end
      end # class Job
    end # class Model
  end # module Jobs
end # module Startback
