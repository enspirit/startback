require 'spec_helper'
require 'startback/web/auto_caching'

module Startback
  module Web
    describe AutoCaching do
      include Rack::Test::Methods

      context 'when used without options' do
        def app
          Rack::Builder.new do
            use AutoCaching
            run ->(env){ [200, {}, ["Hello error"]] }
          end
        end

        it 'sets the development Cache-Control since this is a test' do
          get '/'
          expect(last_response['Cache-Control']). to eql("no-cache, no-store, max-age=0, must-revalidate")
        end
      end

      context 'when forcing production' do
        def app
          Rack::Builder.new do
            use AutoCaching, false
            run ->(env){ [200, {}, ["Hello error"]] }
          end
        end

        it 'sets the production Cache-Control' do
          get '/'
          expect(last_response['Cache-Control']). to eql("public, must-revalidate, max-age=3600, s-max-age=3600")
        end
      end

      context 'when forcing development headers' do
        def app
          Rack::Builder.new do
            use AutoCaching, development: { "Cache-Control" => "no-cache" }
            run ->(env){ [200, {}, ["Hello error"]] }
          end
        end

        it 'sets the production Cache-Control' do
          get '/'
          expect(last_response['Cache-Control']). to eql("no-cache")
        end
      end

      context 'when setting the Cache-Control header only' do
        def app
          Rack::Builder.new do
            use AutoCaching, development: "no-cache"
            run ->(env){ [200, {}, ["Hello error"]] }
          end
        end

        it 'sets the production Cache-Control' do
          get '/'
          expect(last_response['Cache-Control']). to eql("no-cache")
        end
      end

      context 'when a Cache-Control header is already set by the app' do
        def app
          Rack::Builder.new do
            use AutoCaching
            run ->(env){ [200, {"Cache-Control" => "priority"}, ["Hello error"]] }
          end
        end

        it 'sets the production Cache-Control' do
          get '/'
          expect(last_response['Cache-Control']). to eql("priority")
        end
      end

    end # CatchAll
  end # module Web
end # module Startback
