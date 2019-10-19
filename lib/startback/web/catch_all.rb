module Startback
  module Web
    #
    # This Rack middleware catches all exceptions that are raised by sublayers
    # in the Rack chain. It converts them to correct 500 Errors, with a generic
    # exception message encoded in json.
    #
    # This class aims at being used as top level of a Rack chain. It is not
    # aimed at being subclassed.
    #
    # Fatal error cached are also sent as a `fatal` messange, on the error
    # handler provided on Context#error_handler.fatal, if any.
    #
    # Examples:
    #
    #     Rack::Builder.new do
    #       use Startback::Web::CatchAll
    #     end
    #
    class CatchAll < Rack::Robustness
      include Errors
      include Support::Robustness

      FATAL_ERROR = {
        code: "Startback::Errors::InternalServerError",
        description: "An error occured, sorry"
      }.to_json

      self.catch_all
      self.on(Exception)
      self.status 500
      self.content_type 'application/json'
      self.body FATAL_ERROR

      self.ensure(true) do |ex|
        context = env[Context::Middleware::RACK_ENV_KEY]
        begin
          if context && context.respond_to?(:error_handler, true) && context.error_handler
            context.error_handler.fatal(ex)
          else
            log(:fatal, self, "ensure", error: ex)
          end
        rescue => ex2
          STDERR.puts(ex2.message)
          STDERR.puts(ex2.backtrace[0..10].join("\n"))
          raise
        end
      end

    end # class CatchAll
  end # class Web
end # module Startback
