module Startback
  class Context
    class Middleware

      def initialize(app)
        @app = app
      end

      def call(env)
        env['SAMBACK_CONTEXT'] ||= Context.new.tap{|c|
          c.original_rack_env = env.dup
        }
        @app.call(env)
      end

    end # class Middleware
  end # class Context
end # module Startback
