require 'prometheus/client'

module Startback
  module Audit
    #
    # Prometheus exporter abstraction, that can be registered as an around
    # hook on OperationRunner and as a prometheus client on Context instances.
    #
    # The exporter uses the ruby client for prometheus to expose metrics regarding Operation runs.
    #
    # The following metrics are exported:
    #
    # A counter 'operation_errors' (failed runs)
    # A histogram 'operation_calls'
    #
    # All these metrics use the following labels
    # - operation : class name of the operation executed
    #
    # Given that this Exporter is intended to be used as around hook on an
    # `OperationRunner`, operations that fail at construction time will not be
    # exported at all, since they can't be ran in the first place. This may lead
    # to metrics not containing important errors cases if operations check their
    # input at construction time.
    #
    class Prometheus

      def initialize(options = {})
        @registry = ::Prometheus::Client.registry
        @errors = @registry.counter(
          :operation_errors,
          docstring: 'A counter of operation errors',
          labels: [:operation])
        @calls = @registry.histogram(
          :operation_calls,
          docstring: 'A histogram of operation latency',
          labels: [:operation])
      end
      attr_reader :registry, :calls, :errors

      def call(runner, op)
        name = op_name(op)
        result = nil
        time = Benchmark.realtime{ result = yield }
        @calls.observe(time, labels: { operation: name }) rescue nil
        result
      rescue => ex
        @errors.increment(labels: { operation: name }) rescue nil
        raise
      end

    protected

      def op_name(op)
        case op
        when String then op
        when Class  then op.name
        else op.class.name
        end
      end

    end # class Prometheus
  end # module Audit
end # module Startback
