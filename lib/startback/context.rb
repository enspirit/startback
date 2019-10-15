module Startback
  #
  # Defines an execution context for Startback applications.
  #
  # In web application, an instance of a context can be set on the Rack
  # environment, using Context::Middleware.
  #
  # This class SHOULD be subclassed for application required extensions
  # to prevent touching the global Startback state itself.
  #
  # Also, for event handling in distributed architectures, a Context should
  # be dumpable and reloadable to JSON. An `h` information contract if provided
  # for that. Subclasses may contribute to the dumping and reloading process
  # through the `h_dump` and `h_factory` methods
  #
  #     module MyApp
  #       class Context < Startback::Context
  #
  #         attr_accessor :foo
  #
  #         h_dump do |h|
  #           h.merge!("foo" => foo)
  #         end
  #
  #         h_factor do |c,h|
  #           c.foo = h["foo"]
  #         end
  #
  #       end
  #     end
  #
  #
  class Context
    attr_accessor :original_rack_env

    # An error handler can be provided on the Context class. The latter
    # MUST expose an API similar to ruby's Logger class. It can be a logger
    # instance, simply.
    #
    # Fatal errors catched by Web::CatchAll are sent on `error_handler#fatal`
    attr_accessor :error_handler

    class << self

      def h(hash)
        h_factor!(self.new, hash)
      end

      def h_factor!(context, hash)
        h_factories.each do |f|
          f.call(context, hash)
        end
        context
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

      def h_dumpers
        @h_dumpers ||= []
      end

      def h_dump(&dumper)
        h_dumpers << dumper
      end

    end

    def to_h
      self.class.h_dump!(self)
    end

    def to_json(*args, &bl)
      to_h.to_json(*args, &bl)
    end

  end # class Context
end # module Startback
require_relative 'context/middleware'
