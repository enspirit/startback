# Sinatra 4 restricts the Host header to localhost-like values in the
# `development` environment, which is the one used when RACK_ENV is unset.
# Rack::Test issues requests against `example.org`, hence the need to be
# explicit about running in test mode here.
ENV["RACK_ENV"] ||= "test"

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'startback'
require 'startback/jobs'
require 'rack/test'
require 'bmg'

module SpecHelpers
end

RSpec.configure do |c|
  c.include SpecHelpers

  def a_job_data(override = {})
    {
      id: 'abcdef',
      isReady: false,
      opClass: 'CowSay',
      opInput: { 'message' => 'Hello !!', 'crash' => false },
      opContext: {},
      opResult: nil,
      strategy: 'NotReady',
      hasFailed: false,
      strategyOptions: {},
      expiresAt: nil,
      refreshFreq: nil,
      refreshedAt: nil,
      consumeMax: nil,
      consumeCount: 0,
      createdAt: DateTime.now,
      createdBy: 'blambeau',
    }.merge(override)
  end
end

class CowSay < Startback::Operation
  def initialize(input)
    @input = Startback::Model.new(input)
  end

  def call
    raise Startback::Errors::InternalServerError, "Something bad happened" if input.crash
    input.message
  end
end
