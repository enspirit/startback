require 'sinatra'
require 'rack/robustness'
require 'finitio'
require 'logger'
require 'path'
require 'ostruct'
require 'benchmark'

# Provides a reusable backend framework for backend components written
# in ruby.
#
# The framework installs conventions regarding:
#
# - The exposition of web service APIs (Framework::Api, on top of Sinatra)
# - Operations (Framework::Operation)
# - Error handling (Framework::Errors) and their handling in web APIs
#   (based on Rack::Robustness)
# - General code support (Framework::Support modules & classes).
#
# Please refer to the documentation of those main abstractions for details.
#
module Startback

  # Simply checks that a path exists of raise an error
  def self._!(path)
    Path(path).tap do |p|
      raise "Missing #{p.basename}." unless p.exists?
    end
  end

  require_relative 'startback/version'
  require_relative 'startback/ext'
  require_relative 'startback/errors'
  require_relative 'startback/support'
  require_relative 'startback/model'
  require_relative 'startback/context'
  require_relative 'startback/operation'

  # Logger instance to use for the application
  LOGGER = ::Startback::Support::Logger.new

end # module Startback
