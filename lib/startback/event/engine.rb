require 'rack'
require 'webrick'
require 'startback'
module Startback
  class Event
    #
    # This class runs an infinite loop using ServerEngine.
    # It is intended to be used to run jobs that listen to
    # a Startback Bus instance without having the main process
    # terminating immediately.
    #
    # The Engine automatically runs a Webrick small webapp
    # with a /healthcheck webservice. The class can be extended
    # and method `on_health_check` overriden to run specific
    # checks.
    #
    # This class goes hand in hand with the `startback:engine`
    # docker image.
    #
    # Example:
    #
    #     # Dockerfile
    #     FROM enspirit/startback:engine-0.11
    #
    #     # engine.rb
    #     require 'startback/event/engine'
    #     Startback::Event::Engine.run
    #
    class Engine

      DEFAULT_OPTIONS = {
        daemonize: false,
        worker_type: 'process',
        workers: 1
      }

      def initialize
        require 'serverengine'
      end

      def on_health_check
        "Ok"
      end

      def run(options = {})
        options = DEFAULT_OPTIONS.merge(options)
        health = Engine.build_health_check(self)
        worker = Engine.build_worker(health)
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

        def build_worker(health)
          Module.new do
            include Support::Env

            def initialize
              @stop_flag = ServerEngine::BlockingFlag.new
            end

            define_method(:health) do
              health
            end

            def run
              until @stop_flag.set?
                Rack::Handler::WEBrick.run(health, {
                  :Port => env('STARTBACK_ENGINE_PORT', '3000').to_i,
                  :Host => env('STARTBACK_ENGINE_LISTEN', '0.0.0.0')
                })
              end
            end

            def stop
              @stop_flag.set!
              Rack::Handler::WEBrick.shutdown
            end
          end
        end
      end # class << self
    end # class Engine
  end # class Event
end # module Startback
