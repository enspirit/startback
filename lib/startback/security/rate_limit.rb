module Startback
  module Security
    module RateLimit

      def rate_limit(options = {})
        @rate_limit = options
      end

      def has_rate_limit?
        !!@rate_limit
      end

      def rate_limit_options(defaults)
        defaults.merge(@rate_limit || {})
      end

    end # module RateLimit
  end # module Security
end # module Startback
