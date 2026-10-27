require 'rack'

module Startback
  module Web
    #
    # This rack middleware automatically mark response as non being cacheable
    # in development, and being cacheble in production.
    #
    # An error response is never made cacheable, in either mode. Whether a
    # request is answered 4xx usually depends on that very request -- a header,
    # a cookie, a credential -- while a cache in front of the application keys
    # on the url alone, so one client's error would otherwise be served to
    # everyone asking for the url next. It is marked `no-store` rather than
    # merely left alone, because 404 and 410 are heuristically cacheable
    # (RFC 9111) and a shared cache may keep them with no header to go by.
    #
    # The headers to set in development, in production and on an error can be
    # passed at construction, as well as whether the development environment
    # must be forced. This class may also be configured through environment
    # variables:
    #
    # - RACK_ENV: when "production" use the production headers, otherwise use
    #     the development ones
    # - STARTBACK_AUTOCACHING_DEVELOPMENT_CACHE_CONTROL: Cache-Control header
    #     to use in development mode
    # - STARTBACK_AUTOCACHING_PRODUCTION_CACHE_CONTROL: Cache-Control header
    #     to use in production mode
    # - STARTBACK_AUTOCACHING_ERROR_CACHE_CONTROL: Cache-Control header to use
    #     on a response of status 400 and up
    #
    # Example:
    #
    #     # Default configuration
    #     use Autocaching
    #
    #     # Force development mode
    #     use Autocaching, true
    #
    #     # Force production mode
    #     use Autocaching, false
    #
    #     # Set production headers manually
    #     use Autocaching, { :production => "public, no-cache, no-store" }
    #
    #     # Let a shared cache keep a not found for a minute
    #     use Autocaching, { :error => "public, max-age=60" }
    #
    class AutoCaching

      # Cache-Control header to use in development mode
      DEVELOPMENT_CACHE_CONTROL = ENV['STARTBACK_AUTOCACHING_DEVELOPMENT_CACHE_CONTROL'] || \
                                  "no-cache, no-store, max-age=0, must-revalidate"

      # Cache-Control header to use in production mode
      PRODUCTION_CACHE_CONTROL = ENV['STARTBACK_AUTOCACHING_PRODUCTION_CACHE_CONTROL'] ||\
                                 "public, must-revalidate, max-age=3600, s-max-age=3600"

      # Cache-Control header to use on an error response, in either mode
      ERROR_CACHE_CONTROL = ENV['STARTBACK_AUTOCACHING_ERROR_CACHE_CONTROL'] ||\
                            "no-store"

      # Lowest status this middleware considers an error
      ERROR_STATUS = 400

      def initialize(app, development = nil, cache_headers = {})
        development, cache_headers = nil, development if development.is_a?(Hash)
        @app = app
        @development = development.nil? ? infer_is_development : development
        @cache_headers = default_headers.merge(normalize_headers(cache_headers))
      end

      def call(env)
        status, headers, body = @app.call(env)
        [status, patch_response_headers(status, headers), body]
      end

    protected

      # Rack::Headers is used so that the defaults set here are actually
      # overriden by the downstream application, whatever the case it uses
      # for its own header names.
      def patch_response_headers(status, hs)
        Rack::Headers[defaults_for(status)].merge(hs)
      end

      def defaults_for(status)
        return @cache_headers[:error] if status >= ERROR_STATUS

        development? ? @cache_headers[:development] : @cache_headers[:production]
      end

      def development?
        !!@development
      end

      def infer_is_development
        ENV['RACK_ENV'] != "production"
      end

      def default_headers
        {
          development: {
            "cache-control" => DEVELOPMENT_CACHE_CONTROL
          },
          production: {
            "cache-control" => PRODUCTION_CACHE_CONTROL
          },
          error: {
            "cache-control" => ERROR_CACHE_CONTROL
          }
        }
      end

      def normalize_headers(h)
        Hash[h.map{|k,v| [k, v.is_a?(Hash) ? v : {"cache-control" => v} ] }]
      end

    end # class AutoCaching
  end # module Web
end # module Startback
