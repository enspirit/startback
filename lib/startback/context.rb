module Startback
  #
  # Defines an execution context for Startback applications.
  #
  # This class is aimed at being subclassed for application required
  # extension.
  #
  # In web application, an instance of a context can be set on the Rack
  # environment, using Context::Middleware.
  #
  class Context
    attr_accessor :original_rack_env

    # An error handler can be provided on the Context class. The latter
    # MUST expose an API similar to ruby's Logger class. It can be a logger
    # instance, simply.
    #
    # Fatal errors catched by Web::CatchAll are sent on `error_handler#fatal`
    attr_accessor :error_handler

  end # class Context
end # module Startback
require_relative 'context/middleware'
