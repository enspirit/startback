module Startback
  class Context
    module HFactory

      def inherited(subclass)
        subclass.h_factories = h_factories.dup if h_factories?
        subclass.h_dumpers = h_dumpers.dup if h_dumpers?
      end

      def h(hash)
        h_factor!(self.new, hash)
      end

      def h_factor!(context, hash)
        h_factories.each do |f|
          f.call(context, hash)
        end
        context
      end

      def h_factories?
        !!@h_factories && @h_factories.any?
      end

      def h_factories=(factories)
        @h_factories = factories
      end

      def h_factories
        @h_factories ||= []
      end

      def h_factory(&factory)
        h_factories << factory
      end

      ###

      def h_dump!(context, hash = {})
        h_dumpers.each do |d|
          context.instance_exec(hash, &d)
        end
        hash
      end

      def h_dumpers?
        !!@h_dumpers && @h_dumpers.any?
      end

      def h_dumpers
        @h_dumpers ||= []
      end

      def h_dumpers=(dumpers)
        @h_dumpers = dumpers
      end

      def h_dump(&dumper)
        h_dumpers << dumper
      end

    end # module HFactory
  end # class Context
end # module Startback
