module Startback
  module Web
    #
    # This Rack middleware catches all known exceptions raised by sublayers
    # in the Rack chain. Those exceptions are converted to proper HTTP error
    # codes and friendly error messages encoded in json.
    #
    # Please check the Errors module about status codes used for each Startback
    # error.
    #
    # This class aims at being used as top level of a Rack chain.
    #
    # Examples:
    #
    #     Rack::Builder.new do
    #       use Startback::Web::Shield
    #     end
    #
    class Shield < Rack::Robustness
      include Errors

      self.no_catch_all
      self.content_type 'application/json'

      # Decoding errors from json and csv are considered user's fault
      self.on(Finitio::TypeError){ 400 }
      self.on(::NotImplementedError){ 501 }

      # Various other codes for the framework specific error classes
      self.on(Startback::Errors::Error) {|ex|
        ex.class.status
      }

      # A bit of logic to choose the best error message for the user
      # according to the error class
      self.body{|ex|
        body_for(ex).to_json
      }

      def body_for(ex)
        ex = ex.root_cause if ex.is_a?(Finitio::TypeError)
        body = { code: ex.class.name, description: ex.message }
        return body unless ex.is_a?(Startback::Errors::Error)
        return body unless ex.has_causes?

        body[:causes] = ex.causes
          .filter{|cause|
            cause.is_a?(Startback::Errors::Error)
          }
          .map{|cause|
            body_for(cause)
          }
        body
      end

    end # class Shield
  end # module Web
end # module Startback
