require 'startback/audit'

module Startback
  module Security
    #
    # This class can be used as operation arounder to skip operation executions
    # via a rate limiting process.
    #
    # Example:
    #
    #     RATE_LIMITER = Startback::Security::RateLimiter.new({
    #       store: Startback::Caching::Store.new,  # use a redis cache store in practice
    #       defaults: {
    #         strategy: :silent_drop,              # simply ignore the call
    #         detection: :input,                   # method to call on Operation instance to detect call duplicates via pure data
    #         periodicity: 60,                     # periodicity of occurence count, in seconds
    #         max_occurence: 3,                    # max number of occurences during the period
    #       },
    #     })
    #
    #     # in api.rb
    #     around_run(RATE_LIMITER)
    #
    class RateLimiter
      include Support::Robustness

      DEFAULT_OPTIONS = {
        max_occurences: 1
      }

      def initialize(options = {})
        @options = DEFAULT_OPTIONS.merge(options)

        configuration_error!("Missing store") unless @options[:store]
      end

      def call(runner, op, &then_block)
        raise ArgumentError, "A block is required" unless then_block

        if op.class.has_rate_limit?
          limit_options = op.class.rate_limit_options(defaults || {})
          key, authorized = authorize_call!(op, limit_options)
          unless authorized
            log_rate_limited(op, key, limit_options)
            return nil
          end
        end

        then_block.call
      end

    private

      def authorize_call!(op, limit_options)
        key = get_detection_key(op, limit_options)
        count = get_detection_count(key)
        authorize = (count < max_occurences_allowed(limit_options))
        save_detection_count(key, count + 1, limit_options) if authorize
        [key, authorize]
      end

      def get_detection_count(key)
        value = store.get(key)
        value.nil? ? 0 : value.to_i
      end

      def save_detection_count(key, count, limit_options)
        store.set(key, count.to_s, ttl(limit_options))
      end

      def get_detection_key(op, limit_options)
        value = case detection = limit_options[:detection]
        when String
          detection
        when Symbol
          op.send(detection)
        else
          configuration_error!("Unrecognized :detection `#{detection}`")
        end
        key = {
          model: "Startback::Security::RateLimiter",
          op_class: op.class.name.to_s,
          value: value,
        }
        JSON.fast_generate(key)
      end

      def defaults
        @defaults ||= @options[:defaults]
      end

      def store
        @store ||= @options[:store]
      end

      def ttl(limit_options)
        limit_options[:periodicity] || @options[:periodicity] || 60
      end

      def max_occurences_allowed(limit_options)
        limit_options[:max_occurences] || @options[:max_occurences] || 1
      end

      def log_rate_limited(op, key, limit_options)
        logger_for(op).warn({
          op: self.class,
          op_data: { key: key, options: limit_options },
        })
      end

      def configuration_error!(msg)
        raise Startback::Error, msg
      end

    end # class RateLimiter
  end # module Audit
end # module Startback
