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
        @prefix = options[:prefix] || "startback"
        @options = options
        @registry = ::Prometheus::Client.registry
        all_labels = [:operation, :startback_version] + option_labels.keys
        @errors = @registry.counter(
          :"#{prefix}_operation_errors",
          docstring: 'A counter of operation errors',
          labels: all_labels)
        @calls = @registry.histogram(
          :"#{prefix}_operation_calls",
          docstring: 'A histogram of operation latency',
          labels: all_labels)
      end
      attr_reader :registry, :calls, :errors, :options, :prefix

      def call(runner, op)
        name = op_name(op)
        result = nil
        time = Benchmark.realtime{
          result = yield
        }
        ignore_safely {
          @calls.observe(time, labels: get_labels(name))
        }
        result
      rescue => ex
        ignore_safely {
          @errors.increment(labels: get_labels(name))
        }
        raise
      end

    protected

      def ignore_safely
        yield
      rescue => ex
        puts ex.class.to_s + "\n" + ex.message + "\n" + ex.backtrace.join("\n")
        nil
      end

      def get_labels(op_name)
        option_labels.merge({
          operation: op_name,
          startback_version: version
        })
      end

      def option_labels
        @options[:labels] || {}
      end

      def version
        Startback::VERSION
      end

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
