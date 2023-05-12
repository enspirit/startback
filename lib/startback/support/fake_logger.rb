module Startback
  module Support
    class FakeLogger < Logger

      def initialize(*args)
        @seen = []
      end
      attr_accessor :formatter
      attr_reader :seen

      def last_msg
        seen.last
      end

      [:debug, :info, :warn, :error, :fatal].each do |meth|
        define_method(meth) do |msg|
          @seen << format(meth, msg)
        end
      end

      def format(severity, message)
        return message unless formatter

        formatter.call(severity.to_s.upcase, Time.now, 'prognam', message)
      end

    end # class FakeLogger
  end # module Support
end # module Startback
