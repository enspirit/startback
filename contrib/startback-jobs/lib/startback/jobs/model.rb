module Startback
  module Jobs
    class Model < Startback::Model

      def self.dress(data, schema)
        new(System[schema].dress(data))
      end

    end # class Model
  end # module Jobs
end # module Startback
require_relative 'model/job'
