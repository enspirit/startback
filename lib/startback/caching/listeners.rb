module Startback
  module Caching
    class Listeners

      def initialize
        @listeners = []
      end

      def register(listener)
        @listeners << listener
        self
      end
      alias :<< :register

      def cache_hit(*args, &bl)
        @listeners.each do |l|
          l.cache_hit(*args, &bl)
        end
      end

      def cache_outdated(*args, &bl)
        @listeners.each do |l|
          l.cache_outdated(*args, &bl)
        end
      end

      def cache_miss(*args, &bl)
        @listeners.each do |l|
          l.cache_miss(*args, &bl)
        end
      end

      def cache_fail(*args, &bl)
        @listeners.each do |l|
          l.cache_fail(*args, &bl)
        end
      end

    end # class Listeners
  end # module Caching
end # module Startback
