module Startback
  class Bus
    module Helpers

    protected

      def with_error_handling(context = nil, &bl)
        bl.call
      rescue => ex
        if context && context.respond_to?(:error_handler) && context.error_handler
          context.error_handler.fatal(ex)
        else
          STDERR.puts "Startback::Bus::Async error: #{ex.message}"
          STDERR.puts ex.backtrace.join("\n")
        end
      end

    end # module Helpers
  end # class Bus
end # module Klaro
