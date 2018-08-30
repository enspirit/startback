module Gyrb
  class Operation

    attr_accessor :context
    attr_accessor :world

    protected :context=, :world=

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

    def run(operation)
      operation.bind(self.world).call
    end

  end # class Operation
end # module Gyrb
require_relative 'operation/error_operation'
require_relative 'operation/multi_operation'
