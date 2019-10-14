module Startback
  class Operation
    include Errors
    include Support::OperationRunner

    attr_accessor :world

    protected :world=

    def bind(world)
      return self unless world
      dup.tap{|op|
        op.world = world
      }
    end

    def method_missing(name, *args, &bl)
      return super unless args.empty? and bl.nil?
      return super unless world
      world.fetch(name){ super }
    end

  protected

    def operation_world(op)
      self.world
    end

  end # class Operation
end # module Startback
require_relative 'operation/error_operation'
require_relative 'operation/multi_operation'
