module Gyrb
  class Context
    class Middleware

      def initialize(app)
        @app = app
      end

      def call(env)
        env['GYRB_CONTEXT'] ||= Context.new.tap{|c|
          c.original_rack_env = env.dup
        }
        @app.call(env)
      end

    end # class Middleware
  end # class Context
end # module Gyrb
