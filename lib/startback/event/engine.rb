require 'rack'
require 'webrick'
require 'startback'
module Startback
  class Event
    #
    # This class is the starting point of event handling in
    # Startback. It holds a Bus instance to which emitters
    # and listeners can connect, and the possibility for the
    # the listening part to start an infinite loop (ServerEngine).
    #
    # The Engine automatically runs a Webrick small webapp
    # with a /healthcheck webservice. The class can be extended
    # and method `on_health_check` overriden to run specific
    # checks.
    #
    # This class goes hand in hand with the `startback:engine`
    # docker image. It can be extended by subclasses to override
    # the following methods:
    #
    #   - bus to use something else than a simple memory bus
    #   - on_health_check to check specific health conditions
    #   - create_agents to instantiate all listening agents
    #     (unless auto_create_agents is used)
    #
    class Engine
      include Support::Robustness

      DEFAULT_OPTIONS = {

        # To be passed to ServerEngine
        server_engine: {}

      }

      def initialize(options = {}, context = Context.new)
        @options = DEFAULT_OPTIONS.merge(options)
        @context = context
        @context.engine = self
      end
      attr_reader :options, :context

      class << self
        def auto_create_agents?
          !!@auto_create_agents
        end

        # Register a base class which will be used to discover
        # the agents to start when the engine is ran.
        def auto_create_agents(base_class = nil)
          @auto_create_agents ||= base_class
          @auto_create_agents
        end
      end

      # This method is executed on health check and can be
      # overriden by subclasses to perform specific checks.
      def on_health_check
        "Ok"
      end

      def bus
        ::Startback::Event::Bus.new
      end

      def connect
        log(:info, self, "Connecting to the bus now!")
        bus.connect
      end

      def run(options = {})
        connect

        log(:info, self, "Running agents and server engine!")
        create_agents
        Runner.new(self, options[:server_engine] || {}).run
      end

      def create_agents
        return unless parent = self.class.auto_create_agents

        ObjectSpace
          .each_object(Class)
          .select { |klass| klass < parent }
          .each { |klass| klass.new(self) }
      end

      def factor_event(event_data)
        Event.json(event_data, context)
      end

      class Runner

        DEFAULT_SERVER_ENGINE_OPTIONS = {
          daemonize: false,
          worker_type: 'process',
          workers: 1
        }

        def initialize(engine, options = {})
          raise ArgumentError if engine.nil?

          @engine = engine
          @options = DEFAULT_SERVER_ENGINE_OPTIONS.merge(options)
          require 'serverengine'
        end
        attr_reader :engine, :options

        def run(options = {})
          health = self.class.build_health_check(engine)
          worker = self.class.build_worker(engine, health)
          se = ServerEngine.create(nil, worker, options)
          se.run
          se
        end

        class << self
          def run(*args, &bl)
            new.run(*args, &bl)
          end

          def build_health_check(engine)
            Rack::Builder.new do
              map '/health-check' do
                health = Startback::Web::HealthCheck.new {
                  engine.on_health_check
                }
                run(health)
              end
            end
          end

          def build_worker(engine, health)
            Module.new do
              include Support::Env

              def initialize
                @stop_flag = ServerEngine::BlockingFlag.new
              end

              define_method(:health) do
                health
              end

              define_method(:engine) do
                engine
              end

              def run
                ran = false
                until @stop_flag.set?
                  if ran
                    engine.send(:log, :warn, engine, "Restarting internal loop")
                  else
                    engine.send(:log, :info, engine, "Starting internal loop")
                  end
                  Rack::Handler::WEBrick.run(health, {
                    :Port => env('STARTBACK_ENGINE_PORT', '3000').to_i,
                    :Host => env('STARTBACK_ENGINE_LISTEN', '0.0.0.0')
                  })
                  ran = true
                end
              end

              def stop
                engine.send(:log, :info, engine, "Stopping internal loop")
                @stop_flag.set!
                Rack::Handler::WEBrick.shutdown
              end
            end
          end
        end # class << self
      end # class Runner
    end # class Engine
  end # class Event
end # module Startback
