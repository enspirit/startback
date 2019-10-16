module Startback
  module Caching
    #
    # A overriable caching abstraction aiming at making Entity-based caching easy.
    #
    # This class MUST be overriden:
    #
    # * the `load_raw_data` protected method MUST be implemented.
    # * the `full_key` protected method MAY be overriden to provide specific caching
    #   keys, e.g. by using the context.
    # * the `valid?` protected method MAY be overriden to check validity of data
    #   extracted from the cache.
    #
    # An EntityCache takes an actual store at construction. The object must meet the
    # specification writtern in Store. The 'cache' ruby gem can be used in practice.
    #
    class EntityCache

      class << self

        # Default time to live, in seconds
        attr_writer :default_ttl

        def default_ttl
          @default_ttl || (superclass.respond_to?(:default_ttl, true) && superclass.default_ttl) || 3600
        end

      end # class DSL

      def initialize(store, context = nil)
        @store = store
        @context = context
      end
      attr_reader :store, :context

      # Returns the entity corresponding to a given key.
      #
      # If the entity is not in cache, loads it and puts it in cache using
      # the caching options passed as second parameter.
      def get(short_key, caching_options = default_caching_options)
        cache_key = encode_key(full_key(short_key))
        if store.exist?(cache_key)
          cached = store.get(cache_key)
          return cached if valid?(cache_key, cached)
        end
        load_raw_data(short_key).tap{|to_cache|
          store.set(cache_key, to_cache, caching_options)
        }
      end

      # Invalidates the cache under a given key.
      def invalidate(key)
        store.delete(encode_key(full_key(key)))
      end

    protected

      def encode_key(key)
        JSON.fast_generate(key)
      end

      def default_caching_options
        { ttl: self.class.default_ttl }
      end

      def valid?(cache_key, cached)
        true
      end

      def full_key(key)
        key
      end

      def load_raw_data(short_key)
        raise NotImplementedError, "#{self.class.name}#load_raw_data"
      end

    end # class EntityCache
  end # module Caching
end # module Startback
