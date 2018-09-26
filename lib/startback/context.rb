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

  end # class Context
end # module Startback
require_relative 'context/middleware'
