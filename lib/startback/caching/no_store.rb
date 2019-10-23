module Startback
  module Caching
    #
    # Caching store implementation that caches nothing at all.
    #
    class NoStore

      def initialize
      end

      def exist?(key)
        false
      end

      def get(key)
        nil
      end

      def set(key, value, ttl)
        value
      end

      def delete(key)
      end

    end # class NoStore
  end # module Caching
end # module Startback
