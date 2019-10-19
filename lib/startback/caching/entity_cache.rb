module Startback
  module Caching
    #
    # A overriable caching abstraction aiming at making Entity-based caching easy.
    #
    # This class MUST be overriden:
    #
    # * the `load_entity` protected method MUST be implemented to load data from
    #   a primary & context unaware key.
    #
    # * the `primary_key` protected method MAY be implemented to convert candidate
    #   keys (received from ultimate callers) to primary keys. The method is also
    #   a good place to check and/or log the keys actually used by callers.
    #
    # * the `context_free_key` protected method MAY be overriden to provide
    #   domain unrelated caching keys from primary keys, e.g. by encoding the
    #   context into the caching key itself, if needed.
    #
    # * the `valid?` protected method MAY be overriden to check validity of data
    #   extracted from the cache and force a refresh even if found.
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
      def get(candidate_key, caching_options = default_caching_options)
        pkey = primary_key(candidate_key)
        cache_key = encode_key(context_free_key(pkey))
        if store.exist?(cache_key)
          cached = store.get(cache_key)
          return cached if valid?(pkey, cached)
        end
        load_entity(pkey).tap{|to_cache|
          store.set(cache_key, to_cache, caching_options)
        }
      end

      # Invalidates the cache under a given key.
      def invalidate(candidate_key)
        pkey = primary_key(candidate_key)
        cache_key = encode_key(context_free_key(pkey))
        store.delete(cache_key)
      end

    protected

      def default_caching_options
        { ttl: self.class.default_ttl }
      end

      # Converts a candidate key to a primary key, so as to prevent
      # cache duplicates if callers are allowed to request an entity
      # through various keys.
      #
      # The default implementation returns the candidate key and MAY
      # be overriden.
      def primary_key(candidate_key)
        candidate_key
      end

      # Encodes a context free key to an actual cache key.
      #
      # Default implementation uses JSON.fast_generate but MAY be
      # overriden.
      def encode_key(context_free_key)
        JSON.fast_generate(context_free_key)
      end

      # Returns whether `cached` entity seems fresh enough to
      # be returned as a cache hit.
      #
      # This method provides a way to check freshness using, e.g.
      # `updated_at` or `etag` kind of entity fields. The default
      # implementation returns true and MAY be overriden.
      def valid?(primary_key, cached)
        true
      end

      # Converts a primary_key to a context_free_key, using the
      # context (instance variable) to encode the context itself
      # into the actual cache key.
      #
      # The default implementation simply returns the primary key
      # and MAY be overriden.
      def context_free_key(primary_key)
        full_key(primary_key)
      end

      # Deprecated, will be removed in 0.6.0. Use context_free_key
      # instead.
      def full_key(primary_key)
        primary_key
      end

      # Actually loads the entity using the given primary key, and
      # possibly the cache context.
      #
      # This method MUST be implemented and raises a NotImplementedError
      # by default.
      def load_entity(primary_key)
        load_raw_data(primary_key)
      end

      # Deprecated, will be removed in 0.6.0. Use load_entity
      # instead.
      def load_raw_data(*args, &bl)
        raise NotImplementedError, "#{self.class.name}#load_entity"
      end

    end # class EntityCache
  end # module Caching
end # module Startback
