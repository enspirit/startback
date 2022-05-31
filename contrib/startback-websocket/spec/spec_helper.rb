$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'startback'
require 'startback/websocket'
require 'rack/test'

module SpecHelpers

  class SubContext < Startback::Context
    attr_accessor :websocket_app
  end

  class MockSocket
    attr_reader :last_message

    def send(msg)
      @last_message = msg
    end

    def close()
    end

    def on(event, &bl)
    end
  end

  class MockFayeEvent
    def initialize(event)
      @data = event[:data]
      @headers = event[:headers] || {}
    end
    attr_reader :data, :headers
  end

end

RSpec.configure do |c|
  c.include SpecHelpers
end
