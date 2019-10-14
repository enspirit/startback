module Startback
  module Web
    module Middleware

    protected

      def context(env = @env)
        ::Startback::Context::Middleware.context(env) || Errors.server_error!("Unable to find context!!")
      end

    end # module Middleware
  end # module Web
end # module Startback
