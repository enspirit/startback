require 'bmg'
require 'startback'
require 'startback/web/catch_all'
require 'startback/web/shield'
require 'startback/web/prometheus'
require 'startback/web/api'
require 'startback/web/health_check'
require 'startback/websocket'
require 'startback/audit'
require 'startback/event'

module StartbackTodo

  PROMETHEUS = ::Startback::Audit::Prometheus.new({
    prefix: "example"
  })

  TRAILER = ::Startback::Audit::Trailer.new(STDERR)

  DEFAULT_CONTEXT = Startback::Context.new

  require_relative 'startback_todo/model'
  require_relative 'startback_todo/dto'
  require_relative 'startback_todo/event'
  require_relative 'startback_todo/database'
  require_relative 'startback_todo/operation'
  require_relative 'startback_todo/api'
  require_relative 'startback_todo/errors'
  require_relative 'startback_todo/websocket_app'
  require_relative 'startback_todo/webpoint'
  require_relative 'startback_todo/agent'
  require_relative 'startback_todo/engine'

  DB = Database.new

  ENGINE = Engine.new({}, DEFAULT_CONTEXT)

end # module StartbackTodo
