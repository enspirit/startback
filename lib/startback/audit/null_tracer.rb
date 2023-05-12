module Startback
  module Audit
    class NullTracer

      def attached?
        false
      end

      def last_span!
        nil
      end

      def new_trace(*args)
        self
      end

      def attach_to(*args)
        self
      end

      def fork(*args)
        yield
      end

      def on_span(listener = nil, &block)
        self
      end

    end # class NullTracer
  end # module Audit
end # module Startback
