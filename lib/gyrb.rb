require 'sinatra'
require 'rack/robustness'
require 'finitio'
require 'bmg'
require 'logger'
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
module Gyrb

  # Simply checks that a path exists of raise an error
  def self._!(path)
    Path(path).tap do |p|
      raise "Missing #{p.basename}." unless p.exists?
    end
  end

  require_relative 'gyrb/ext'
  require_relative 'gyrb/errors'
  require_relative 'gyrb/support'
  require_relative 'gyrb/context'
  require_relative 'gyrb/operation'
  require_relative 'gyrb/web'

  # Logger instance to use for the application
  LOGGER = ::Gyrb::Support::Logger.new

end # module Gyrb
