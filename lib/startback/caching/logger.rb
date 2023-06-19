module Startback
  module Caching
    class Logger
      include Support::Robustness

      def cache_hit(entity_cache, context, pkey, cached)
        log(:debug, entity_cache, "cache_hit", context, op_data: pkey)
      end

      def cache_outdated(entity_cache, context, pkey, cached)
        log(:info, entity_cache, "cache_outdated", context, op_data: pkey)
      end

      def cache_miss(entity_cache, context, pkey)
        log(:info, entity_cache, "cache_miss", context, op_data: pkey)
      end

      def cache_fail(entity_cache, context, pkey, ex)
        log(:error, entity_cache, "cache_fail", context, op_data: pkey, error: ex)
      end

    end # class Logger
  end # module Caching
end # module Startback
