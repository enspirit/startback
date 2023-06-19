require 'prometheus/client'

module Startback
  module Caching
    class Prometheus

      def initialize
        @cache_hit_counter = cache_counter('hit')
        @cache_outdated_counter = cache_counter('outdated')
        @cache_miss_counter = cache_counter('miss')
        @cache_fail_counter = cache_counter('fail')
      end

      def cache_hit(entity_cache, *args, &bl)
        @cache_hit_counter.increment(labels: {
          entity_cache: entity_cache.class.name,
        })
      end

      def cache_outdated(entity_cache, *args, &bl)
        @cache_outdated_counter.increment(labels: {
          entity_cache: entity_cache.class.name,
        })
      end

      def cache_miss(entity_cache, *args, &bl)
        @cache_miss_counter.increment(labels: {
          entity_cache: entity_cache.class.name,
        })
      end

      def cache_fail(entity_cache, *args, &bl)
        @cache_fail_counter.increment(labels: {
          entity_cache: entity_cache.class.name,
        })
      end

    private

      def cache_counter(what)
        name = "entity_cache_#{what}".to_sym
        ::Prometheus::Client::Counter.new(
          name,
          docstring: "A counter of EntityCache #{what}",
          labels: [:entity_cache],
        ).tap do |counter|
          ::Prometheus::Client.registry.register(counter)
        end
      end

    end # class Prometheus
  end # module Caching
end # module Startback
