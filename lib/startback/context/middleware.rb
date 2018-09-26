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
    #       use Startback::Context::Middleware, context_class: MyContextClass
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

      DEFAULT_OPTIONS = {
        context_class: Context
      }

      def initialize(app, options = {})
        @app = app
        @options = DEFAULT_OPTIONS.merge(options || {})
      end
      attr_reader :options

      def call(env)
        env[RACK_ENV_KEY] ||= options[:context_class].new.tap{|c|
          c.original_rack_env = env.dup
        }
        @app.call(env)
      end

    end # class Middleware
  end # class Context
end # module Startback
