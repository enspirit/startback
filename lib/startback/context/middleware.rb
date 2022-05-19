module Startback
  class Context
    #
    # Rack middleware that installs a particular context instance
    # on the Rack environment.
    #
    # Examples:
    #
    #     # Use the default context class
    #     Rack::Builder.new do
    #       use Startback::Context::Middleware
    #
    #       run ->(env){
    #         ctx = env[Startback::Context::Middleware::RACK_ENV_KEY]
    #         ctx.is_a?(Startback::Context) # => true
    #       }
    #     end
    #
    #     # Use a user defined context class
    #     Rack::Builder.new do
    #       use Startback::Context::Middleware, MyContextClass.new
    #
    #       run ->(env){
    #         ctx = env[Startback::Context::Middleware::RACK_ENV_KEY]
    #         ctx.is_a?(MyContextClass)     # => true (your subclass)
    #         ctx.is_a?(Startback::Context) # => true (required!)
    #       }
    #     end
    #
    class Middleware

      RACK_ENV_KEY = 'SAMBACK_CONTEXT'

      def initialize(app, context = Context.new)
        @app = app
        @context = context
      end
      attr_reader :context

      def call(env)
        env[RACK_ENV_KEY] ||= context.dup.tap{|c|
          c.original_rack_env = env.dup
        }
        @app.call(env)
      end

      def self.context(env)
        env[RACK_ENV_KEY]
      end

    end # class Middleware
  end # class Context
end # module Startback
