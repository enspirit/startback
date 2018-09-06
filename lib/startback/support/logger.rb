module Startback
  module Support
    #
    # A Logger extension that sends info and debug messages to STDOUT
    # and other messages to STDERR. This is not configurable.
    #
    class Logger < ::Logger

      def initialize
        super(STDOUT)
        @err_logger = ::Logger.new(STDERR)
      end

      def self.level=(level)
        super.tap{
          @err_logger.level = level
        }
      end

      def warn(*args, &bl)
        @err_logger.warn(*args, &bl)
      end

      def error(*args, &bl)
        @err_logger.error(*args, &bl)
      end

      def fatal(*args, &bl)
        @err_logger.fatal(*args, &bl)
      end

    end # class Logger
  end # module Support
end # module Startback
