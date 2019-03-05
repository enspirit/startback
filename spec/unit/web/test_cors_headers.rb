require 'spec_helper'
require 'singleton'

module Startback
  module Web
    describe CorsHeaders do
      include Rack::Test::Methods

      context 'when used without options' do
        def app
          Rack::Builder.new do
            use CorsHeaders
            run ->(env){ [200, {}, ["Hello world"]] }
          end
        end

        it 'sets the CORS headers to default values' do
          header('Origin', "https://test.com")
          get '/'
          expect(last_response['Access-Control-Allow-Origin']). to eql("*")
          expect(last_response['Access-Control-Allow-Methods']). to eql("OPTIONS, HEAD, GET, POST, PUT, PATCH, DELETE")
          expect(last_response.body).to eql("Hello world")
        end

        it 'strips everything when option' do
          header('Origin', "https://test.com")
          options '/'
          expect(last_response['Access-Control-Allow-Origin']). to eql("*")
          expect(last_response['Access-Control-Allow-Methods']). to eql("OPTIONS, HEAD, GET, POST, PUT, PATCH, DELETE")
          expect(last_response.status).to eql(204)
          expect(last_response.body).to eql("")
        end
      end

      context 'when used with the :bounce option' do
        def app
          Rack::Builder.new do
            use CorsHeaders, bounce: true
            run ->(env){ [200, {}, ["Hello world"]] }
          end
        end

        it 'sets the CORS Origin header to the caller' do
          header('Origin', "https://test.com")
          get '/'
          expect(last_response['Access-Control-Allow-Origin']). to eql("https://test.com")
          expect(last_response['Access-Control-Allow-Methods']). to eql("OPTIONS, HEAD, GET, POST, PUT, PATCH, DELETE")
          expect(last_response.body).to eql("Hello world")
        end
      end

      context 'when overriding a header' do
        def app
          Rack::Builder.new do
            use CorsHeaders, headers: { 'Access-Control-Allow-Methods' => "POST" }
            run ->(env){ [200, {}, ["Hello world"]] }
          end
        end

        it 'sets the CORS Origin header to the caller' do
          header('Origin', "https://test.com")
          get '/'
          expect(last_response['Access-Control-Allow-Origin']). to eql("*")
          expect(last_response['Access-Control-Allow-Methods']). to eql("POST")
          expect(last_response.body).to eql("Hello world")
        end
      end

      context 'when the app sets specific headers' do
        def app
          Rack::Builder.new do
            use CorsHeaders
            run ->(env){ [200, {'Access-Control-Allow-Methods' => "POST"}, ["Hello world"]] }
          end
        end

        it 'does not override them' do
          header('Origin', "https://test.com")
          get '/'
          expect(last_response['Access-Control-Allow-Origin']). to eql("*")
          expect(last_response['Access-Control-Allow-Methods']). to eql("POST")
          expect(last_response.body).to eql("Hello world")
        end
      end

    end # CatchAll
  end # module Web
end # module Startback
