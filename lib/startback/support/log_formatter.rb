module Startback
  module Support
    class LogFormatter

      def call(severity, time, progname, msg)
        {
          severity: severity,
          time: time
        }.merge(msg)
         .merge(error: error_to_json(msg[:error], severity))
         .compact
         .to_json << "\n"
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

    end # class LogFormatter
  end # module Support
end # module Startback
