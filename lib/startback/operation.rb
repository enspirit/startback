module Startback
  #
  # High-level Operation abstraction, that is a piece of code that executes
  # on demand and (generally) changes the state of the software system.
  #
  # An operation is basically an object that respond to `call`, but that
  # executes within a given world (see `bind`). It also has before and
  # after hooks that allows specifying what needs to be done before invoking
  # call and after having invoked it. All this protocol is actually under
  # the responsibility of an `OperationRunner`. Operations should not be
  # called manually by third-party code.
  #
  # Example:
  #
  #     class SayHello < Startback::Operation
  #
  #       before_call do
  #         # e.g. check_some_permissions
  #       end
  #
  #       def call
  #         puts "Hello"
  #       end
  #
  #       after_call do
  #         # e.g. log and/or emit something on a bus
  #       end
  #
  #     end
  #
  class Operation
    include Errors
    include Support::OperationRunner
    include Support::Hooks.new(:call)

    attr_accessor :world
    protected :world=

    def bind(world)
      return self unless world
      self.world = world
      self
    end

    def method_missing(name, *args, &bl)
      return super unless args.empty? and bl.nil?
      return super unless world
      world.fetch(name){ super }
    end

    def respond_to?(name, *args)
      super || (world && world.has_key?(name))
    end

    def with_context(ctx = nil)
      old_world = self.world
      self.world = self.world.merge(context: ctx || old_world.context.dup)
      result = ctx ? yield : yield(self.world.context)
      self.world = old_world
      result
    end

  protected

    def operation_world(op)
      self.world
    end

  end # class Operation
end # module Startback
require_relative 'operation/error_operation'
require_relative 'operation/multi_operation'
