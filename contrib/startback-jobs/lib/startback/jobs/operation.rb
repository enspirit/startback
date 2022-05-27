module Startback
  module Jobs
    class Operation < Startback::Operation
    end # class Operation
  end # module Jobs
end # module Startback
require_relative 'operation/create_job'
require_relative 'operation/run_job'
