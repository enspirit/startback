require 'spec_helper'
require 'singleton'
require 'startback/web/catch_all'

module Startback
  module Web
    describe CatchAll do
      include Rack::Test::Methods

      context 'when used without context' do
        def app
          Rack::Builder.new do
            use CatchAll
            run ->(env){ raise "Hello error" }
          end
        end

        it 'returns a 500 with json explanation' do
          get '/'
          expect(last_response.status).to eql(500)
          expect(last_response.content_type).to eql("application/json")
          result = JSON.parse(last_response.body)
          expect(result).to eql({
            "code" => "Startback::Errors::InternalServerError",
            "description" => "An error occured, sorry"
          })
        end
      end

      context 'when used with a context providing an error handler' do

        class AnError < StandardError
        end

        class ErrorHandler
          include Singleton

          attr_reader :ex

          def fatal(ex)
            @ex = ex
          end

        end

        class MyContextWithErrorHandler < Startback::Context

          def error_handler
            ErrorHandler.instance
          end

        end

        def app
          Rack::Builder.new do
            use Context::Middleware, MyContextWithErrorHandler.new
            use CatchAll
            run ->(env){ raise AnError, "Hello error" }
          end
        end

        it 'returns a 500 with json explanation' do
          get '/'
          expect(last_response.status).to eql(500)
          expect(last_response.content_type).to eql("application/json")
          result = JSON.parse(last_response.body)
          expect(result).to eql({
            "code" => "Startback::Errors::InternalServerError",
            "description" => "An error occured, sorry"
          })
          expect(ErrorHandler.instance.ex).to be_a(AnError)
        end
      end

    end # CatchAll
  end # module Web
end # module Startback
