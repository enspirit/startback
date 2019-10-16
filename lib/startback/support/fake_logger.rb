module Startback
  module Support
    class FakeLogger < Logger

      def initialize(*args)
        @last_msg = nil
      end
      attr_reader :last_msg

      [:debug, :info, :warn, :error, :fatal].each do |meth|
        define_method(meth) do |msg|
          @last_msg = msg
        end        
      end

    end # class Logger
  end # module Support
end # module Startback
