require 'bmg'
require 'startback'
require 'startback/web/catch_all'
require 'startback/web/shield'
require 'startback/web/prometheus'
require 'startback/web/api'
require 'startback/web/health_check'
require 'startback/audit'

module StartbackTodo

  PROMETHEUS = ::Startback::Audit::Prometheus.new({
    prefix: "example"
  })

  require_relative 'startback_todo/errors'
  require_relative 'startback_todo/model'
  require_relative 'startback_todo/dto'
  require_relative 'startback_todo/database'
  require_relative 'startback_todo/operation'
  require_relative 'startback_todo/api'
  require_relative 'startback_todo/webpoint'

  DB = Database.new

end # module StartbackTodo
