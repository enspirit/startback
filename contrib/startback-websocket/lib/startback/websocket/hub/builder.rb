
module Startback
  module Websocket
    module Hub
      class Builder

        def initialize(context, default_handler = nil, *bl_args, &bl)
          @context = context
          @default_handler = default_handler
          @middlewares = []
          @commands = {}
          @rooms = {}
          @bl_args
          instance_exec *bl_args, &bl
        end

        def use(middleware, *opts)
          @middlewares << proc { |app| middleware.new(app, *opts) }
        end

        def command(name, &bl)
          cname = name.to_sym
          raise "Command #{name} already defined: #{name}" if @commands[cname]
          @commands[cname] = proc { |app| Middleware::CommandHandler.new(app, { :name => name }, &bl) }
          @middlewares << @commands[cname]
        end

        def room(name, &bl)
          raise "Room names must be strings" unless name.is_a? String
          raise "Room '#{name}' already defined" if @rooms[name]

          @rooms[name] ||= Room.new(name)
          handler = Builder.new(@context, nil, @rooms[name], &bl).to_handler
          middleware = proc { |app| Middleware::RoomHandler.new(app, @rooms[name], handler) }

          @middlewares << middleware
        end

        def to_handler
          default_handler = @default_handler || proc {}
          @middlewares
            .reverse
            .reduce(default_handler) do |handler, mw|
              mw.call(handler)
            end
        end

        def to_websocket_app
          App.new(@context, @rooms, to_handler)
        end

      end # class Builder
    end # module Hub
  end # module Websocket
end # module Startback
