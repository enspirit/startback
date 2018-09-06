$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'startback'
require 'rack/test'

module SpecHelpers
end

RSpec.configure do |c|
  c.include SpecHelpers
end
