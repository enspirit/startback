module Startback
  module Web
    #
    # This rack middleware automatically mark response as non being cacheable
    # in development, and being cacheble in production.
    #
    # The headers to set in development and production can be passed at
    # construction, as well as whether the development environment must be
    # forced. This class may also be configured through environment variables:
    #
    # - RACK_ENV: when "production" use the production headers, otherwise use
    #     the development ones
    # - STARTBACK_AUTOCACHING_DEVELOPMENT_CACHE_CONTROL: Cache-Control header
    #     to use in development mode
    # - STARTBACK_AUTOCACHING_PRODUCTION_CACHE_CONTROL: Cache-Control header
    #     to use in production mode
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
    class AutoCaching

      # Cache-Control header to use in development mode
      DEVELOPMENT_CACHE_CONTROL = ENV['STARTBACK_AUTOCACHING_DEVELOPMENT_CACHE_CONTROL'] || \
                                  "no-cache, no-store, max-age=0, must-revalidate"

      # Cache-Control header to use in produdction mode
      PRODUCTION_CACHE_CONTROL = ENV['STARTBACK_AUTOCACHING_PRODUCTION_CACHE_CONTROL'] ||\
                                 "public, must-revalidate, max-age=3600, s-max-age=3600"

      def initialize(app, development = nil, cache_headers = {})
        development, cache_headers = nil, development if development.is_a?(Hash)
        @app = app
        @development = development.nil? ? infer_is_development : development
        @cache_headers = default_headers.merge(normalize_headers(cache_headers))
      end

      def call(env)
        status, headers, body = @app.call(env)
        [status, patch_response_headers(headers), body]
      end

    protected

      def patch_response_headers(hs)
        (development? ? @cache_headers[:development] : @cache_headers[:production]).merge(hs)
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
            "Cache-Control" => DEVELOPMENT_CACHE_CONTROL
          },
          production: {
            "Cache-Control" => PRODUCTION_CACHE_CONTROL
          }
        }
      end

      def normalize_headers(h)
        Hash[h.map{|k,v| [k, v.is_a?(Hash) ? v : {"Cache-Control" => v} ] }]
      end

    end # class AutoCaching
  end # module Web
end # module Startback
