module Startback
  module Support
    class LogFormatter

      DEFAULT_OPTIONS = {
        pretty_print: nil
      }

      def initialize(options = {}, redactor = default_redactor)
        @options = DEFAULT_OPTIONS.merge(options)
        @options[:pretty_print] = auto_pretty_print unless @options.has_key?(:pretty_print)
        @redactor = redactor
      end

      def pretty_print?
        !!@options[:pretty_print]
      end

      def call(severity, time, progname, msg)
        msg = { message: msg } if msg.is_a?(String)
        msg = { error: msg } if msg.is_a?(Exception)
        data = {
          severity: severity,
          time: time
        }.merge(msg)
         .merge(error: error_to_json(msg[:error], severity))
         .compact
        data = @redactor.redact(data)
        if pretty_print?
          JSON.pretty_generate(data) << "\n"
        else
          data.to_json << "\n"
        end
      end

      def error_to_json(error, severity = nil)
        return error if error.nil?
        return error if error.is_a?(String)
        return error.to_s unless error.is_a?(Exception)

        backtrace = error.backtrace[0..25] if severity == "FATAL"
        causes = error.causes.map{|c| error_to_json(c) } if error.respond_to?(:causes)
        causes = nil if causes && causes.empty?
        {
          message: error.message,
          backtrace: backtrace,
          causes: causes
        }.compact
      end

    private

      def default_redactor
        Support::Redactor.new
      end

      def auto_pretty_print
        development?
      end

    end # class LogFormatter
  end # module Support
end # module Startback
