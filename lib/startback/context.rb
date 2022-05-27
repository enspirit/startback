module Startback
  #
  # Defines an execution context for Startback applications, and provides
  # a cached factory for related abstractions (see `factor`), and an
  # extensible world, statically and dynamically.
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
  class Context
    attr_accessor :original_rack_env

    # An error handler can be provided on the Context class. The latter
    # MUST expose an API similar to ruby's Logger class. It can be a logger
    # instance, simply.
    #
    # Fatal errors catched by Web::CatchAll are sent on `error_handler#fatal`
    #
    # Deprecated, use the logger below instead.
    attr_accessor :error_handler

    # A logger can be provided on the context, and will be used for everything
    # related to logging, audit trailing and robustness. The logger receives
    # object following the log & trail conventions of Startback, and must
    # convert them to wathever log format is necessary.
    attr_accessor :logger

    require_relative 'context/h_factory'
    extend(Context::HFactory)

    def initialize
      super
      yield(self) if block_given?
    end

    attr_writer :_world
    protected :_world=

    def self.world(who, &block)
      @_world ||= Support::World.new
      @_world = @_world.factory(who, &block)
    end

    def self.factor_world(context)
      @_world ||= Support::World.new
      @_world.with_scope(context)
    end

    def world
      @_world ||= self.class.factor_world(self)
    end

    def with_world(world)
      dup do |ctx|
        ctx._world = self.world.with(world)
      end
    end

    # Factors an instance of `clazz`, which must be a Context-related
    # abstraction (i.e. its constructor takes the context as last parameters).
    #
    # Factored abstractions are cached for a given context & arguments.
    def factor(clazz, *args)
      @factored ||= {}
      key = args.empty? ? clazz : [clazz] + args
      @factored[key] ||= clazz.new(*(args << self))
    end

    def clean_factored!
      @factored = {}
    end
    private :clean_factored!

    def to_h
      self.class.h_dump!(self)
    end

    def to_json(*args, &bl)
      to_h.to_json(*args, &bl)
    end

    def fork(h = nil)
      dup.tap{|duped|
        self.class.h_factor!(duped, h) if h
        yield(duped) if block_given?
      }
    end

    def dup
      super.tap{|c|
        c.send(:clean_factored!)
        yield(c) if block_given?
      }
    end

  end # class Context
end # module Startback
require_relative 'context/middleware'
