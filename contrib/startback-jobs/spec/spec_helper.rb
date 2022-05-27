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
      opInput: { 'message' => 'Hello !!' },
      opContext: {},
      opResult: nil,
      strategy: 'NotReady',
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
    input.message
  end
end
