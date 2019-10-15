module Startback
  module Support
    #
    # Support module for high-level architectural components that
    # execute operations as part of their logic, see e.g. Web::Api.
    #
    # This module contributes a `run` instance method that allows
    # binding an operation with a world, and executing it while
    # supporting around runners.
    #
    # Example:
    #
    #     class HighLevelComponent
    #       include Startback::Support::OperationRunner
    #
    #       def some_method
    #         # Runs the operation passed after some binding
    #         run SomeOperation.new
    #       end
    #
    #     protected
    #
    #       # Overriden to inject some extra world
    #       def operation_world(op)
    #         super(op).merge({ hello: "world" })
    #       end
    #
    #       # Execute this around op
    #       around_run do |op, then_block|
    #         puts "About to run #{op.inspect}"
    #         then_block.call
    #       end
    #
    #       # SomeClass#call will be called with the operation
    #       # as first parameter and a block as continuation
    #       around_run SomeClass.new
    #
    #     end
    #
    module OperationRunner

      # Contributes the hook DSL methods to classes that include
      # the OperationRunner module
      module ClassMethods

        # Registers a callable to be executed around operation running.
        #
        # In its block form, the callable is `instance_exec`uted on the
        # runner instance, with the operation passed as first parameter
        # and a then_block callable as second parameter (continuation):
        #
        #     around_run do |op,then_block|
        #       # do whatever you want with the op (already bounded)
        #       puts op.inspect
        #
        #       # do not forget to call the continuation block
        #       then_block.call
        #     end
        #
        # With a parameter responding to `#call`, the latter is invoked
        # with the operation as parameter and a block as continuation:
        #
        #     class Arounder
        #
        #       def call(op)
        #         # do whatever you want with the op (already bounded)
        #         puts op.inspect
        #
        #         # do not forget to call the continuation block
        #         yield
        #       end
        #
        #     end
        #
        def around_run(arounder = nil, &bl)
          raise ArgumentError, "Arg or block required" unless arounder || bl
          arounds(true) << [arounder || bl, arounder.nil?]
        end

      private

        def arounds(create = false)
          if create
            @arounds ||= superclass.respond_to?(:arounds, true) \
                       ? superclass.send(:arounds, true).dup \
                       : []
          end
          @arounds || (superclass.respond_to?(:arounds, true) ? superclass.send(:arounds, true) : [])
        end

      end

      # When included by a class/module, install the DSL methods
      def self.included(by)
        by.extend(ClassMethods)
      end

      # Runs `operation`, taking care of binding it and executing
      # hooks.
      #
      # This method is NOT intended to be overriden. Use hooks and
      # `operation_world` to impact default behavior.
      def run(operation)
        op_world = operation_world(operation)
        op_bound = operation.bind(op_world)
        _run_befores(op_bound)
        r = _run_with_arounds(op_bound, self.class.send(:arounds))
        _run_afters(op_bound)
        r
      end

    protected

      # Returns the world to use to bind an operation.
      #
      # The default implementation returns an empty hash. This is
      # intended to be overriden by classes including this module.
      def operation_world(op)
        {}
      end

    private

      def _run_befores(op_bound)
        op_bound.before_call if op_bound.respond_to?(:before_call)
      end

      def _run_with_arounds(operation, arounds = [])
        if arounds.empty?
          operation.call
        else
          arounder, iexec = arounds.first
          after_first = ->() {
            _run_with_arounds(operation, arounds[1..-1])
          }
          if iexec
            self.instance_exec(operation, after_first, &arounder)
          else
            arounder.call(self, operation, &after_first)
          end
        end
      end

      def _run_afters(op_bound)
        op_bound.after_call if op_bound.respond_to?(:after_call)
      end

    end # module OperationRunner
  end # module Support
end # module Startback
