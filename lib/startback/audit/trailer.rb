require_relative 'shared'
require 'forwardable'
module Startback
  module Audit
    #
    # Log & Audit trail abstraction, that can be registered as an around
    # hook on OperationRunner and as an actual logger on Context instances.
    #
    # The trail is outputted as JSON lines, using a Logger on the "device"
    # passed at construction. The following JSON entries are dumped:
    #
    # - severity  : INFO or ERROR
    # - time      : ISO8601 Datetime of operation execution
    # - op        : class name of the operation executed
    # - op_took   : Execution duration of the operation
    # - op_data   : Dump of operation input data
    # - context   : Execution context, through its `h` information contract (IC)
    #
    # Dumping of operation data follows the following duck typing conventions:
    #
    # - If the operation instance responds to `to_trail`, this data is taken
    # - If the operation instance responds to `input`, this data is taken
    # - If the operation instance responds to `request`, this data is taken
    # - Otherwise op_data is a JSON null
    #
    # By contributing to the Context's `h` IC, users can easily dump information that
    # makes sense (such as the operation execution requester).
    #
    # The class implements a sanitization process when dumping the context and
    # operation data. Blacklisted words taken in construction options are used to
    # prevent dumping hash keys that match them (insentively). Default stop words
    # are equivalent to:
    #
    #     Trailer.new("/var/log/trail.log", {
    #       blacklist: "token password secret credential"
    #     })
    #
    # Please note that the sanitization process does not apply recursively if
    # the operation data is hierarchic. It only applies to the top object of
    # Hash and [Hash]. Use `Operation#to_trail` to fine-tune your audit trail.
    #
    # Given that this Trailer is intended to be used as around hook on an
    # `OperationRunner`, operations that fail at construction time will not be
    # trailed at all, since they can't be ran in the first place. This may lead
    # to trails not containing important errors cases if operations check their
    # input at construction time.
    #
    class Trailer
      include Shared
      extend Forwardable
      def_delegators :@logger, :debug, :info, :warn, :error, :fatal

      DEFAULT_OPTIONS = {

        # Words used to stop dumping for, e.g., security reasons
        blacklist: "token password secret credential"

      }

      def initialize(device, options = {})
        @options = DEFAULT_OPTIONS.merge(options)
        @logger = ::Logger.new(device, 'daily')
        @logger.formatter = Support::LogFormatter.new
      end
      attr_reader :logger, :options

      def call(runner, op)
        result = nil
        time = Benchmark.realtime{ result = yield }
        logger.info(op_to_trail(op, time))
        result
      rescue Startback::Errors::BadRequestError => ex
        logger.warn(op_to_trail(op, time, ex))
        raise
      rescue => ex
        logger.error(op_to_trail(op, time, ex))
        raise
      end

    protected

      def op_to_trail(op, time = nil, ex = nil)
        log_msg = {
          op_took: time ? time.round(8) : nil,
          op: op_name(op),
          context: op_context(op),
          op_data: op_data(op)
        }.compact
        log_msg[:error] = ex if ex
        log_msg
      end

      def op_context(op)
        sanitize(op.respond_to?(:context, false) ? op.context.to_h : {})
      end

      def op_data(op)
        data = if op.respond_to?(:op_data, false)
          op.op_data
        elsif op.respond_to?(:to_trail, false)
          op.to_trail
        elsif op.respond_to?(:input, false)
          op.input
        elsif op.respond_to?(:request, false)
          op.request
        elsif op.is_a?(Operation::MultiOperation)
          op.ops.map{ |sub_op| op_to_trail(sub_op) }
        end
        sanitize(data)
      end

      def sanitize(data)
        case data
        when Hash, OpenStruct
          data.dup.delete_if{|k| k.to_s =~ blacklist_rx }
        when Enumerable
          data.map{|elm| sanitize(elm) }.compact
        else
          data
        end
      end

      def blacklist_rx
        @blacklist_rx ||= Regexp.new(
          options[:blacklist].split(/\s+/).join("|"),
          Regexp::IGNORECASE
        )
      end

    end # class Trailer
  end # module Audit
end # module Startback
