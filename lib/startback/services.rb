module Startback
  class Services
    include Startback::Errors

    def initialize(context)
      @context = context
    end
    attr_reader :context

  end # class Services
end # module Startback
