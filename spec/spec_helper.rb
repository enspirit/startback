require 'startback'
require 'startback/event'
require 'startback/support/fake_logger'
require 'rack/test'
require 'ostruct'

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
