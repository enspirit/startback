module Startback
  module Security
    module RateLimit

      def rate_limit(options = {})
        @rate_limit = options
      end

      def has_rate_limit?
        !!@rate_limit
      end

      def rate_limit_options(op, defaults)
        case @rate_limit
        when NilClass then defaults
        when Hash then defaults.merge(@rate_limit)
        when Symbol then defaults.merge(op.send(@rate_limit))
        else
          raise ArgumentError
        end
      end

    end # module RateLimit
  end # module Security
end # module Startback
