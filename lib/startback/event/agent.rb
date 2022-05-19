module Startback
  class Event
    #
    # An agent listen to specific events and react with its
    # `call` method.
    #
    # This class is intended to be subclasses and the following
    # methods overriden:
    #
    #   - install_listeners that installs sync and async listeners
    #   - call to create a context and implement reaction behavior
    #
    class Agent
      include Support::OperationRunner
      include Support::Robustness

      def initialize(engine)
        @engine = engine
        @context = nil
        install_listeners
      end
      attr_reader :engine
      attr_accessor :context
      protected :context=

    protected

      # Installs the various event handlers by calling `sync`
      # and `async` methods.
      #
      # This method is intended to be overriden.
      def install_listeners
      end

      # Returns the underlying bus
      def bus
        engine.bus
      end

      # Asynchronously listen to a specific event.
      #
      # See Bus#listen
      def async(exchange, queue)
        bus.async.listen(exchange, queue) do |event_data|
          event = engine.factor_event(event_data)
          with_context(event.context).call(event)
        end
      end

      # Synchronously listen to a specific event.
      #
      # See Bus#listen
      def sync(exchange, queue)
        bus.listen(exchange, queue) do |event_data|
          event = engine.factor_event(event_data)
          with_context(event.context).call(event)
        end
      end

      # Reacts to a specific event.
      #
      # This method must be implemented by subclasses and raises
      # an error by default.
      def call(event = nil)
        log(:fatal, {
          op: self.class,
          op_data: event,
          error: %Q{Unexpected call to Startback::Event::Agent#call},
          backtrace: caller
        })
        raise NotImplementedError
      end

      def with_context(context)
        dup.tap{|a| a.send(:context=, context) }
      end

      def operation_world(op)
        super(op).merge(context: ctx)
      end

    end # class Agent
  end # class Event
end # module Starback
