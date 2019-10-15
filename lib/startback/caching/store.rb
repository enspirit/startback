module Startback
  module Caching
    #
    # Caching store specification & dummy implementation.
    #
    # This class should not be used in real project, as it implements
    # See the 'cache' gem that provides conforming implementations.
    #
    class Store

      def initialize
        @saved = {}
      end
      attr_reader :saved

      def exist?(key)
        saved.has_key?(key)
      end

      def get(key)
        saved[key]
      end

      def set(key, value, ttl)
        saved[key] = value
      end

      def delete(key)
        saved.delete(key)
      end

    end # class Store
  end # module Caching
end # module Startback
