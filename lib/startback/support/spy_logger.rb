module Startback
  module Support
    #
    # A Logger extension that spies message for inspection during integration
    # testing
    #
    class SpyLogger < ::Logger

      def initialize(*args, &bl)
        super(*args, &bl)
        reset_spy_state!
      end

      def reset_spy_state!
        @state = Hash.new
      end

      def has?(severity, match = {})
        @state[severity] && @state[severity].find{|x|
          match.each_pair.all?{|(k,v)| x[k] == v }
        }
      end

      def spy(severity, args)
        @state[severity] ||= []
        @state[severity] << args[0]
      end

      [ :info, :warn, :error, :fatal ].each {|meth|
        define_method(meth) do |*args, &bl|
          spy(meth, args)
          super(*args, &bl)
        end
      }

    end # class SpyLogger
  end # module Support
end # module Startback
