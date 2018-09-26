module Startback
  module Web
    #
    # Can be used to easily implement a HealthCheck web service inside a Startback
    # application.
    #
    # Examples:
    #
    #     # Returns a 204 with no body
    #     run Startback::Web::HealthCheck.new
    #
    #     # Returns a 204 with no body
    #     run Startback::Web::HealthCheck.new { nil }
    #
    #     # Returns a 200 with Ok in plain text
    #     run Startback::Web::HealthCheck.new { "Ok" }
    #
    #     # Re-raises the exception
    #     run Startback::Web::HealthCheck.new { raise "Something bad" }
    #
    # Please note that this rack app is not 100% Rack compliant, since it raises
    # any error that the block itself raises. This class aims at being backed up
    # by a Shield and/or CatchAll middleware.
    #
    # This class is not aimed at being subclassed.
    #
    class HealthCheck

      def initialize(&bl)
        @checker = bl
      end

      def call(env)
        if debug_msg = check!(env)
          [ 200, { "Content-Type" => "text/plain" }, debug_msg ]
        else
          [ 204, {}, "" ]
        end
      end

    protected

      def check!(env)
        @checker.call if @checker
      end

    end # class HealthCheck
  end # module Web
end # module Startback
