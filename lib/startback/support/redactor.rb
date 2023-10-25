module Startback
  module Support
    class Redactor

      DEFAULT_OPTIONS = {

        # Words used to stop dumping for, e.g., security reasons
        blacklist: "token password secret credential email address"

      }

      def initialize(options = {})
        @options = DEFAULT_OPTIONS.merge(options)
      end

      def redact(data)
        case data
        when Hash, OpenStruct
          Hash[data.map{|(k,v)|
            [k, (k.to_s =~ blacklist_rx) ? '---redacted---' : redact(v)]
          }]
        when Enumerable
          data.map{|elm| redact(elm) }.compact
        when /:\/\//
          data.gsub(/:\/\/([^@]+[@])/){|m| "://--redacted--@" }
        else
          data
        end
      end

    private

      def blacklist_rx
        @blacklist_rx ||= Regexp.new(
          @options[:blacklist].split(/\s+/).join("|"),
          Regexp::IGNORECASE
        )
      end

    end # class Redactor
  end # module Support
end # module Startback
