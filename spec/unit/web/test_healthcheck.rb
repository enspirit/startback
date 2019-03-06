require 'spec_helper'
require 'startback/web/health_check'

module Startback
  module Web
    describe HealthCheck do
      include Rack::Test::Methods

      context 'when used without a block and no failure' do
        def app
          HealthCheck.new
        end

        it 'returns a 204 when ok' do
          get '/'
          expect(last_response.status).to eql(204)
          expect(last_response.body).to be_empty
        end
      end

      context 'when used without a block a failure' do
        def app
          app = HealthCheck.new
          def app.check!(env)
            raise "Hello error"
          end
          app
        end

        it 'raises when ko' do
          expect(->(){ get '/' }).to raise_error("Hello error")
        end
      end

      context 'when used with a block returning a debug message' do
        def app
          HealthCheck.new{ "Hello world" }
        end

        it 'returns a 200 with plain text message' do
          get '/'
          expect(last_response.status).to eql(200)
          expect(last_response.body).to eql("Hello world")
        end
      end

      context 'when used with a block raising an exception' do
        def app
          HealthCheck.new{ raise("Hello error") }
        end

        it 're-raises it' do
          expect(->(){ get '/' }).to raise_error("Hello error")
        end
      end

    end
  end # module Web
end # module Startback
