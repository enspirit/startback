module Startback
  module Support
    class World
      include DataObject

      attr_accessor :_factory
      protected :_factory=

      def factory(who, &block)
        dup.tap do |x|
          x._factory = (self._factory || {}).merge(who => block)
        end
      end

      attr_accessor :_scope
      protected :_scope=

      def with_scope(scope)
        dup.tap do |x|
          x._scope = scope
        end
      end

      def with(hash)
        dup.tap do |x|
          x._data = to_data.merge(hash)
        end
      end

    private

      def _data_allow_camelize
        false
      end

      def _data_allow_query
        false
      end

      def _data_key_not_found(key)
        raise Startback::Error, "Scope must be defined" unless s = _scope

        block = (_factory || {})[key]
        if block
          factored = s.instance_exec(&block)
          @_data = @_data.dup.merge(key => factored).freeze
          [key, false]
        else
          nil
        end
      end
    end # class World
  end # module Support
end # module Startback
