module Startback
  module Audit
    class TraceLogger

      def initialize(logger = default_logger)
        @logger = logger || default_logger
        @logger.formatter ||= Support::LogFormatter.new if @logger.respond_to?(:formatter=)
      end

      def call(span)
        if !span.finished?
          @logger.debug(span.to_h)
        elsif span.success?
          @logger.info(span.to_h)
        elsif span&.error.is_a?(Startback::Errors::BadRequestError)
          @logger.warn(span.to_h)
        else
          @logger.error(span.to_h)
        end
      end

    private

      def default_logger
        ::Logger.new(STDOUT, 'daily')
      end

    end # class TraceLogger
  end # module Audit
end # module Startback
