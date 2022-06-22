module Startback
  module Web
    #
    # Sets Cross-Origin Response Headers on requests specifying an Origin
    # HTTP header, according configuration passed at construction and/or
    # environment variables.
    #
    # Example:
    #
    #     # Default configuration, using environment variables when set
    #     use CorsHeaders
    #
    #     # Force a bouncing of the origin, using the Origin request header
    #     # as Access-Control-Allow-Origin response header
    #     use CorsHeaders, bounce: true
    #
    #     # Force a bouncing of the origin, but only for whitelisted candidates
    #     use CorsHeaders, bounce: ['https://*.test.com', 'https://*.test.devel']
    #
    #     # The option above also works with a comma-separated string
    #     use CorsHeaders, bounce: 'https://*.test.com,https://*.test.devel'
    #
    #     # Overrides a specific header
    #     use CorsHeaders, headers: { 'Access-Control-Allow-Methods' => 'POST' }
    #
    class CorsHeaders

      ALLOW_ORIGIN = ENV['STARTBACK_CORS_ALLOW_ORIGIN'] || '*'

      ALLOW_METHODS = ENV['STARTBACK_CORS_ALLOW_METHODS'] || 'OPTIONS, HEAD, GET, POST, PUT, PATCH, DELETE'

      ALLOW_CREDENTIALS = ENV['STARTBACK_CORS_ALLOW_CREDENTIALS'] || 'true'

      MAX_AGE = ENV['STARTBACK_CORS_MAX_AGE'] || '1728000'

      ALLOW_HEADERS = ENV['STARTBACK_CORS_ALLOW_HEADERS'] || 'Authorization, Content-Type, Origin, Accept, If-Modified-Since, If-Match, If-None-Match'

      EXPOSE_HEADERS = ENV['STARTBACK_CORS_EXPOSE_HEADERS'] || 'Location, ETag, Last-Modified, Content-Type'

      DEFAULT_CORS_HEADERS = {
        'Access-Control-Allow-Origin' => ALLOW_ORIGIN,
        'Access-Control-Allow-Methods' => ALLOW_METHODS,
        'Access-Control-Allow-Credentials' => ALLOW_CREDENTIALS,
        'Access-Control-Max-Age' => MAX_AGE,
        'Access-Control-Allow-Headers' => ALLOW_HEADERS,
        'Access-Control-Expose-Headers' => EXPOSE_HEADERS
      }

      DEFAULT_OPTIONS = {
        :headers => DEFAULT_CORS_HEADERS
      }

      def initialize(app, options = {})
        @app = app
        @options = Startback::Support.deep_merge(DEFAULT_OPTIONS, options)
        @options[:bounce] = compile_bounce!(@options[:bounce])
      end

      def call(env)
        status, headers, body = @app.call(env)
        if origin = env['HTTP_ORIGIN']
          headers = cors_headers(origin).merge(headers)
        end
        if env['REQUEST_METHOD'] == 'OPTIONS'
          headers['Content-Length'] = '0'
          status, headers, body = [204, headers, []]
        end
        [status, headers, body]
      end

    private

      def cors_headers(origin)
        headers = @options[:headers].dup
        if bounce = do_bounce(origin)
          headers['Access-Control-Allow-Origin'] = bounce
        else
          headers.delete('Access-Control-Allow-Origin')
        end
        headers
      end

      def compile_bounce!(bounce)
        case bounce
        when TrueClass
          true
        when FalseClass, NilClass
          nil
        when Regexp
          bounce
        when String
          rx_str = bounce
            .split(',')
            .map{|b| b.gsub(/\*/, '[^.]+') }
            .join('|')
          Regexp.new("^(#{rx_str})$")
        when Array
          compile_bounce!(bounce.join(','))
        else
          nil
        end
      end

      def do_bounce(origin)
        case bounce = @options[:bounce]
        when NilClass
          @options[:headers]['Access-Control-Allow-Origin']
        when TrueClass
          origin
        when Regexp
          bounce =~ origin ? origin : nil
        else
          nil
        end
      end

    end # class AllowCors
  end # class CorsHeaders
end # module Samback
