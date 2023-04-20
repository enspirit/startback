require 'rack'
require 'startback'
module Startback
  class Event
    #
    # This class is the starting point of event handling in
    # Startback. It holds a Bus instance to which emitters
    # and listeners can connect.
    #
    # The Engine exposes a rack app (.rack_app) with a /healthcheck webservice.
    # It is supposed to be mounted to a webserver such as puma.
    #
    # This class goes hand in hand with the `startback:engine`
    # docker image. It can be extended by subclasses to override
    # the following methods:
    #
    #   - bus to use something else than a simple memory bus
    #   - on_health_check to check specific health conditions
    #   - create_agents to instantiate all listening agents
    #     (unless auto_create_agents is used)
    #   - rack_app if you want to customize the API running
    #
    class Engine
      include Support::Robustness

      DEFAULT_OPTIONS = {

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
        @bus ||= ::Startback::Event::Bus.new
      end

      def connect
        log(:info, self, "Connecting to the bus now!")
        bus.connect
      end

      def create_agents(type = :all)
        return unless parent = self.class.auto_create_agents

        ObjectSpace
          .each_object(Class)
          .select { |klass| klass <= parent }
          .each { |klass| klass.new(self, type) }
      end

      def factor_event(event_data)
        Event.json(event_data, context)
      end

      def rack_app
        engine = self
        Rack::Builder.new do
          use Startback::Web::CatchAll

          map '/health-check' do
            health = Startback::Web::HealthCheck.new {
              engine.on_health_check
            }
            run(health)
          end
        end
      end

    end # class Engine
  end # class Event
end # module Startback
