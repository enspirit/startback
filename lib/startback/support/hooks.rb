module Startback
  module Support
    class Hooks < Module

      def initialize(suffix)
        @suffix = suffix
        define_method :"before_#{suffix}" do
          self.class.__befores.each do |bl|
            instance_exec(&bl)
          end
        end
        define_method :"after_#{suffix}" do
          self.class.__afters.each do |bl|
            instance_exec(&bl)
          end
        end
      end
      attr_reader :suffix

      def included(by)
        by.instance_eval %Q{
          def __befores(create = false)
            if create
              @__befores ||= (superclass.respond_to?(:__befores) ? superclass.__befores.dup : [])
            end
            @__befores || (superclass.respond_to?(:__befores) ? superclass.__befores : [])
          end

          def __afters(create = false)
            if create
              @__afters ||= (superclass.respond_to?(:__afters) ? superclass.__afters.dup : [])
            end
            @__afters || (superclass.respond_to?(:__afters) ? superclass.__afters : [])
          end

          def before_#{suffix}(&bl)
            __befores(true) << bl
          end

          def after_#{suffix}(&bl)
            __afters(true) << bl
          end
        }
      end

    end # class Hooks
  end # module Support
end # module Startback
