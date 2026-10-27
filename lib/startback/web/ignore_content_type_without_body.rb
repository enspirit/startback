require 'rack'

module Startback
  module Web
    #
    # This Rack middleware drops the content type of a request that carries no
    # body, that is, of a GET or a HEAD.
    #
    # A `Content-Type: multipart/form-data; boundary=...` on a GET makes Rack
    # parse a form out of a body that is not there and raise
    # `Rack::Multipart::EmptyContentError`, which Sinatra turns into a 400
    # before the route is ever reached. The answer therefore has nothing to do
    # with what the url serves, and crawlers send exactly that header. Rack is
    # inconsistent here rather than strict: the same request with
    # `Content-Length: 0` parses to no parameters at all.
    #
    # Mount it on an application whose GETs and HEADs ignore the request's
    # content type, which is the usual case -- content negotiation reads
    # `Accept`. An application with a GET route that loads a body (see
    # `Startback::Web::Api#loaded_body`) would see that body become
    # unsupported, hence the opt-in.
    #
    # Examples:
    #
    #     Rack::Builder.new do
    #       use Startback::Web::IgnoreContentTypeWithoutBody
    #     end
    #
    class IgnoreContentTypeWithoutBody

      BODYLESS_METHODS = %w[GET HEAD]

      def self.ignore_content_type?(env)
        BODYLESS_METHODS.include?(env["REQUEST_METHOD"]) && env.key?("CONTENT_TYPE")
      end

      def initialize(app)
        @app = app
      end

      def call(env)
        env.delete("CONTENT_TYPE") if self.class.ignore_content_type?(env)
        @app.call(env)
      end

    end # class IgnoreContentTypeWithoutBody
  end # module Web
end # module Startback
