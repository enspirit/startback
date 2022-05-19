module Startback
  module Support
    #
    # This module provides helper methods for robustness of a software design.
    #
    # It is included by main Startback abstractions, and can be included by
    # specific software components who needs fine-tuning of monitoring, logging
    # and error handling.
    #
    # All public methods here follow the following free args parameters:
    #
    # 1. First (& second) argument(s) form the log message.
    #
    #    A full log message is a Hash having :op (required), :op_took (optional),
    #    and :op_data (optional) keys.
    #
    #    If a String (or two) are used instead, a log message will be built taking
    #    the former as the executer (a class or instance) and the second as a method.
    #    `{ op: "executer#method" }`
    #
    # 2. The second (or third) argument should be a Logger instance, a Context,
    #    or an instance knowing its context. The best logger is extracted from it
    #    and used for actual logging.
    #
    # Examples:
    #
    #     log(:info, op: "hello", op_data: {foo: 12})    => logged as such on STDOUT
    #     log(:info, "A simple message")                 => { op: "A simple message" } on STDOUT
    #     log(:info, Startback, "hello")                 => { op: "Startback#hello"  } on STDOUT
    #     log(:info, Event.new, "hello")                 => { op: "Event#hello" }      on STDOUT
    #     log(:info, Event.new, "hello", "hello world")  => { op: "Event#hello", op_data: { message: "hello world" } } on STDOUT
    #     log(:info, self, context)                      => { op: "..." } on context's logger or STDOUT
    #     log(:info, self, event)                        => { op: "..." } on event context's logger or STDOUT
    #     ...
    #
    module Robustness

      # Included to avoid poluting the space of the including
      # classes.
      module Tools

        def default_logger
          @@default_logger ||= begin
            l = ::Logger.new(STDOUT)
            l.formatter = LogFormatter.new
            l.warn(op: "#{self}", op_data: { msg: "Using default logger to STDOUT" })
            @@default_logger = l
          end
          @@default_logger
        end
        module_function :default_logger

        def logger_for(arg)
          return arg if arg.is_a?(::Logger)
          return arg.logger if arg.is_a?(Context) && arg.logger
          return logger_for(arg.context) if arg.respond_to?(:context, false)
          default_logger
        end
        module_function :logger_for

        def parse_args(log_msg, method = nil, context = nil, extra = nil)
          method, context, extra = nil, method, context unless method.is_a?(String)
          context, extra = nil, context if context.is_a?(Hash) || context.is_a?(String) && extra.nil?
          extra = { op_data: { message: extra } } if extra.is_a?(String)
          logger = logger_for(context) || logger_for(log_msg)
          log_msg = if log_msg.is_a?(Hash)
            log_msg.dup
          elsif log_msg.is_a?(String)
            log_msg = { op: "#{log_msg}#{method.nil? ? '' : '#'+method.to_s}" }
          elsif log_msg.is_a?(Exception)
            log_msg = { error: log_msg }
          else
            log_msg = log_msg.class unless log_msg.is_a?(Module)
            log_msg = { op: "#{log_msg.name}##{method}" }
          end
          log_msg.merge!(extra) if extra
          [ log_msg, logger ]
        end
        module_function :parse_args

        [:debug, :info, :warn, :error, :fatal].each do |meth|
          define_method(meth) do |args, extra = nil, &bl|
            act_args = (args + [extra]).compact
            log_msg, logger = parse_args(*act_args)
            logger.send(meth, log_msg)
          end
          module_function(meth)
        end

      end # module Tools

      # Logs a specific message with a given severity.
      #
      # Severity can be :debug, :info, :warn, :error or :fatal.
      # The args must follow module's conventions, see above.
      def log(severity, *args)
        Tools.send(severity, args)
      end

      # Calls the block and monitors then log its execution time.
      #
      # The args must follow module's conventions, see above.
      def monitor(*args, &bl)
        result = nil
        took = Benchmark.realtime {
          result = bl.call
        }
        Tools.info(args, op_took: took)
        result
      end

      # Executes the block without letting errors propagate.
      # Errors are logged, though. Nothing is logged if everything
      # goes fine.
      #
      # The args must follow module's conventions, see above.
      def stop_errors(*args, &bl)
        result = nil
        took = Benchmark.realtime {
          result = bl.call
        }
        result
      rescue => ex
        Tools.fatal(args, op_took: took, error: ex)
        nil
      end

      # Tries executing the block up to `n` times, until an attempt
      # succeeds (then returning the result). Logs the first and last
      # fatal error, if any.
      #
      # The args must follow module's conventions, see above.
      def try_max_times(n, *args, &bl)
        retried = 0
        took = 0
        begin
          result = nil
          took += Benchmark.realtime {
            result = bl.call
          }
          result
        rescue => ex
          Tools.error(args + [{op_took: took, error: ex}]) if retried == 0
          retried += 1
          if retried < n
            sleep(retried)
            retry
          else
            Tools.fatal(args + [{op_took: took, error: ex}])
            raise
          end
        end
      end

    end # module Robustness
  end # module Support
end # module Startback
