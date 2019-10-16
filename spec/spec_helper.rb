$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'startback'
require 'startback/bus'
require 'startback/support/fake_logger'
require 'rack/test'

module SpecHelpers
end

RSpec.configure do |c|
  c.include SpecHelpers
end
