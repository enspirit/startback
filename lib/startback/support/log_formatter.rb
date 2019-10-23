module Startback
  module Support
    class LogFormatter

      def call(severity, time, progname, msg)
        if msg[:error] && msg[:error].respond_to?(:message, true)
          msg[:backtrace] = msg[:error].backtrace[0..25] if severity == "FATAL"
          msg[:error] = msg[:error].message
        end
        {
          severity: severity,
          time: time,
        }.merge(msg).to_json << "\n"
      end

    end # class LogFormatter
  end # module Support
end # module Startback
