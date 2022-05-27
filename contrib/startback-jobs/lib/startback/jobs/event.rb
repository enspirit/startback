module Startback
  module Jobs
    class Event < Startback::Event
    end # class Event
  end # module Jobs
end # module Startback
require_relative 'event/job_created'
require_relative 'event/job_ran'
