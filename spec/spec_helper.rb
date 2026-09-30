# Sinatra 4 restricts the Host header to localhost-like values in the
# `development` environment, which is the one used when RACK_ENV is unset.
# Rack::Test issues requests against `example.org`, hence the need to be
# explicit about running in test mode here.
ENV["RACK_ENV"] ||= "test"

require 'startback'
require 'startback/caching'
require 'startback/event'
require 'startback/support/fake_logger'
require 'startback/audit'
require 'startback/security'
require 'rack/test'
require 'ostruct'
require 'support/bunny_broker'

module SpecHelpers
end

RSpec.configure do |c|
  c.include SpecHelpers
end

class SubContext < Startback::Context

  attr_accessor :foo

  h_factory do |c,h|
    c.foo = h["foo"]
  end

  h_dump do |h|
    h.merge!("foo" => foo)
  end

  world(:partner) do
    Object.new
  end

end

class SubContext

  attr_accessor :bar

  h_factory do |c,h|
    c.bar = h["bar"]
  end

  h_dump do |h|
    h.merge!("bar" => bar)
  end

end

class User
  class Changed < Startback::Event
  end
end
