module Startback
  module Audit
    class Middleware

      def initialize(app)
        @app = app
      end

      def call(env)
        context = ::Startback::Context::Middleware.context(env)

        # attach to the existing trace if any
        trace_id = env['HTTP_X_TRACE_ID']
        span_id = env['HTTP_X_SPAN_ID']
        context.tracer = context.tracer.attach_to(trace_id, span_id) if trace_id && span_id

        # trace it!
        context.trace_span({
          :type => :request_handler,
          :method => env['REQUEST_METHOD'],
          :path => env['PATH_INFO'],
          :qs => env['QUERY_STRING']
        }) do
          @app.call(env)
        end
      end

    end # class Middleware
  end # module Audit
end # module Startback
