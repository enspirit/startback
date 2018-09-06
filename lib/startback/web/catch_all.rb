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
    # Examples:
    #
    #     Rack::Builder.new do
    #       use Startback::CatchAll
    #     end
    #
    class CatchAll < Rack::Robustness
      include Errors

      FATAL_ERROR = {
        code: "Gybr::Errors::ServerError",
        description: "An error occured, sorry"
      }.to_json

      self.catch_all
      self.status 500
      self.content_type 'application/json'
      self.body FATAL_ERROR.to_json

      self.ensure(true) do |ex|
        Startback::LOGGER.fatal(ex)
      end

    end # class CatchAll
  end # class Web
end # module Startback
