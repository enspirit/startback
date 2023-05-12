module Startback
  module Audit
    class Span

      def initialize(trace_id, parent_id, attributes = {}, span_id = SecureRandom.uuid)
        @trace_id, @parent_id = trace_id, parent_id
        @span_id = span_id
        @attributes = attributes
        @status = 'unknown'
        @at = (Time.now.to_f*1000).to_i
        @timing = nil
        @error = nil
      end
      attr_reader :trace_id, :parent_id, :span_id, :status, :attributes, :timing, :error

      def finished?
        @status != 'unknown'
      end

      def success?
        @status == 'success'
      end

      def error?
        @status == 'error'
      end

      def fork(attributes = {})
        Span.new(@trace_id, @span_id, attributes)
      end

      def finish(timing, error = nil)
        @timing = timing
        @status = error ? 'error' : 'success'
        @error = error
        self
      end

      def to_h
        {
          :spanId => span_id,
          :traceId => trace_id,
          :parentId => parent_id,
          :status => status,
          :timing => timing_to_h,
          :attributes => attributes,
          :error => error,
        }.compact
      end

      def timing_to_h
        {
          at: @at,
          total: @timing&.total,
          real: @timing&.real,
        }.compact
      end
      private :timing_to_h

      def to_json(*args, &block)
        to_h.to_json(*args, &block)
      end

    end # class Span
  end # module Audit
end # module Startback
