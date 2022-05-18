module Startback
  module Support
    # This method provides the `env` and `env!` methods that
    # help querying environment variables easily.
    module Env

      # Returns an environment variable or raise an error if
      # not set.
      #
      # The result is always a String with no leading/trailing
      # spaces.
      #
      # If a block is given, the environment variable is yield
      # and the result of the block returned.
      def env!(key, default = nil, &bl)
        v = ENV[key].to_s.strip
        raise Startback::Error, "Missing ENV var `#{key}`" if v.empty?

        env(key, default, &bl)
      end
      module_function :env!

      # Returns an environment variable or the default value
      # passed as second argument.
      #
      # The result is always a String with no leading/trailing
      # spaces.
      #
      # If a block is given, the environment variable is yield
      # and the result of the block returned.
      def env(key, default = nil, &bl)
        v = ENV[key].to_s.strip
        v = v.empty? ? default : v
        v = bl.call(v) if bl && v
        v
      end
      module_function :env

    end # module Env
  end # module Support
end # module Startback
