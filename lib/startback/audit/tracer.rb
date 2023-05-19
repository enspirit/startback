require 'securerandom'
require 'benchmark'

module Startback
  module Audit
    class Tracer

      def initialize(stack = [], listeners = [], redactor = default_redactor)
        @stack = stack
        @listeners = listeners
        @redactor = redactor
      end
      attr_reader :stack

      def self.empty
        Tracer.new
      end

      def attached?
        !@stack.empty?
      end

      def last_span!
        error!("Trace not attached") unless attached?

        @stack.last
      end

      def new_trace(attributes = {})
        error!("Trace already attached") if attached?

        attach_to(SecureRandom.uuid, SecureRandom.uuid, attributes)
      end

      def attach_to(trace_id, span_id, attributes = {}, parent_id = nil)
        error!("Trace already attached") if attached?

        initial_span = Span.new(trace_id, parent_id, attributes, span_id)
        initial_stack = [ initial_span ]
        Tracer.new(initial_stack, @listeners, @redactor)
      end

      def fork(attributes = {}, &block)
        attributes = @redactor.redact(attributes)
        span = last_span!.fork(attributes)
        @stack << span
        propagate_to_listeners(span)
        result, error = nil, nil
        timing = Benchmark.measure do
          result, error = exec_block_with_error_handling(block)
        end
        error ? raise(error) : result
      ensure
        unless stack.empty?
          span = @stack.pop.finish(timing, error)
          propagate_to_listeners(span)
        end
      end

      def on_span(listener = nil, &block)
        @listeners << (listener || block)
        self
      end

    private

      def default_redactor
        Support::Redactor.new
      end

      def exec_block_with_error_handling(block)
        [ block.call, nil ]
      rescue => ex
        [ nil, ex ]
      end

      def error!(msg)
        raise Startback::Errors::InternalServerError, msg
      end

      def propagate_to_listeners(span)
        @listeners.each do |listener|
          listener.call(span) rescue nil
        end
      end

    end # class Tracer
  end # module Audit
end # module Startback
