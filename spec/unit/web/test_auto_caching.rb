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

      context 'when the application answers an error in production' do
        def cache_control_for(status)
          app = Rack::Builder.new do
            use AutoCaching, false
            run ->(env){ [status, {}, ["Hello error"]] }
          end.to_app
          _, headers, _ = app.call(Rack::MockRequest.env_for("/"))
          headers["cache-control"]
        end

        # A cache in front of the application keys on the url, while the error
        # is about this request; the production policy would hand it to every
        # later visitor of the url.
        it 'forbids storing a bad request' do
          expect(cache_control_for(400)).to eql("no-store")
        end

        it 'forbids storing a not found, heuristically cacheable otherwise' do
          expect(cache_control_for(404)).to eql("no-store")
        end

        it 'forbids storing a server error' do
          expect(cache_control_for(500)).to eql("no-store")
        end

        it 'still makes a redirect cacheable' do
          expect(cache_control_for(301)).to eql("public, must-revalidate, max-age=3600, s-max-age=3600")
        end
      end

      context 'when the error policy is set manually' do
        def app
          Rack::Builder.new do
            use AutoCaching, false, error: "public, max-age=60"
            run ->(env){ [404, {}, ["Hello error"]] }
          end
        end

        it 'uses it rather than the default one' do
          get '/'
          expect(last_response['Cache-Control']).to eql("public, max-age=60")
        end
      end

      context 'when the application sets its own Cache-Control on an error' do
        def app
          Rack::Builder.new do
            use AutoCaching, false
            run ->(env){ [404, {"cache-control" => "public, max-age=60"}, ["Hello error"]] }
          end
        end

        it 'lets the application win, as on a success' do
          get '/'
          expect(last_response['Cache-Control']).to eql("public, max-age=60")
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

      context 'when a lowercase cache-control header is already set by the app' do
        # This is what Rack 3 applications actually emit, Sinatra 4 included.
        # The raw response triple is inspected here on purpose: Rack::Test
        # normalizes header names on read, and would hide a duplicate.
        subject do
          app = Rack::Builder.new do
            use AutoCaching
            run ->(env){ [200, {"cache-control" => "priority"}, ["Hello error"]] }
          end.to_app
          _, headers, _ = app.call(Rack::MockRequest.env_for("/"))
          headers
        end

        it 'lets the application win, and does not duplicate the header' do
          expect(subject.keys.grep(/cache-control/i)).to eql(["cache-control"])
          expect(subject["cache-control"]).to eql("priority")
        end
      end

    end # CatchAll
  end # module Web
end # module Startback
