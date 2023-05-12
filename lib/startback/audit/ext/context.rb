module Startback
  class Context
    attr_accessor :tracer

    def tracer
      @tracer ||= Audit::Tracer.empty.on_span(
        Audit::TraceLogger.new(logger)
      )
    end

    def trace_span(attributes = {}, &block)
      @tracer = tracer.new_trace unless tracer.attached?
      tracer.fork(attributes, &block)
    end

    h_dump do |h|
      next unless tracer.attached?

      last_span = tracer.last_span!
      h.merge!("tracing" => {
        "trace_id" => last_span.trace_id,
        "span_id" => last_span.span_id,
        "parent_id" => last_span.parent_id,
      })
    end

    h_factory do |c, h|
      next unless h['tracing']

      trace_id = h['tracing']['trace_id']
      span_id = h['tracing']['span_id']
      c.tracer = c.tracer.attach_to(trace_id, span_id)
    end
  end # class Context
end # module Startback
