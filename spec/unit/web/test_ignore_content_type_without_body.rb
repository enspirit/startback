require 'spec_helper'
require 'sinatra/base'
require 'startback/web/ignore_content_type_without_body'

module Startback
  module Web
    describe IgnoreContentTypeWithoutBody do
      include Rack::Test::Methods

      MULTIPART_CTYPE = "multipart/form-data; boundary=----WebKitFormBoundaryJ2mHj"

      context 'what the application sees' do
        # Reported as a header rather than a body, so that a HEAD can be
        # asserted on the same way as a GET.
        def app
          Rack::Builder.new do
            use IgnoreContentTypeWithoutBody
            run ->(env){ [200, { "x-seen-content-type" => env["CONTENT_TYPE"].to_s }, []] }
          end
        end

        def seen_content_type
          last_response["x-seen-content-type"]
        end

        it 'hides the content type a GET has no business sending' do
          get '/', {}, "CONTENT_TYPE" => MULTIPART_CTYPE
          expect(seen_content_type).to eql("")
        end

        it 'hides it from a HEAD too' do
          head '/', {}, "CONTENT_TYPE" => MULTIPART_CTYPE
          expect(seen_content_type).to eql("")
        end

        it 'leaves the content type of a POST alone, body or no body' do
          post '/', {}, "CONTENT_TYPE" => MULTIPART_CTYPE
          expect(seen_content_type).to eql(MULTIPART_CTYPE)
        end
      end

      # Rack only parses the form, and only raises, when a body is there to
      # read and no content length says how long it is -- which is what a
      # server hands over for a GET. Rack::Test provides neither on its own.
      def get_with_bogus_content_type
        get '/', {}, {
          "CONTENT_TYPE" => MULTIPART_CTYPE,
          "rack.input" => StringIO.new('')
        }
      end

      class Page < Sinatra::Base
        set :raise_errors, true
        set :show_exceptions, false

        get('/') { "hello" }
      end

      context 'on a sinatra application that serves a GET' do
        def app
          Rack::Builder.new do
            use IgnoreContentTypeWithoutBody
            run Page
          end
        end

        it 'serves the page instead of raising on the absent body' do
          get_with_bogus_content_type
          expect(last_response.status).to eql(200)
          expect(last_response.body).to eql("hello")
        end
      end

      context 'on the same application, unprotected' do
        def app
          Page
        end

        # Which is what this middleware exists for. The day Rack stops telling
        # an empty multipart body apart from a missing one, this fails and the
        # middleware can go.
        it 'answers a 400 that has nothing to do with the url' do
          get_with_bogus_content_type
          expect(last_response.status).to eql(400)
          expect(last_response.body).to include("Invalid multipart/form-data")
        end
      end

    end # IgnoreContentTypeWithoutBody
  end # module Web
end # module Startback
