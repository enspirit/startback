require 'path'
require 'finitio'
require 'startback'
require 'startback/event'
require 'startback/web/api'

module Startback
  module Jobs
    require_relative 'jobs/version'
    require_relative 'jobs/support'
    require_relative 'jobs/model'
    require_relative 'jobs/event'
    require_relative 'jobs/operation'
    require_relative 'jobs/services'
    require_relative 'jobs/api'
    require_relative 'jobs/agent'

    require_relative './ext'

    Finitio.stdlib_path(Path.dir.parent)

    System = Finitio.system(Path.dir/'jobs.fio')
  end
end
