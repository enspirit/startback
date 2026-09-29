# Sinatra 4 restricts the Host header to localhost-like values in the
# `development` environment, which is the one used when RACK_ENV is unset.
# Rack::Test issues requests against `example.org`, hence the need to be
# explicit about running in test mode here.
ENV["RACK_ENV"] ||= "test"

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'startback'
require 'startback/web/magic_assets'
require 'rack/test'

module SpecHelpers
end
