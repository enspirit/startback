module Startback
  module Web
    class Api < Sinatra::Base
      include Support
      include Errors

      set :raise_errors, true
      set :show_exceptions, false

    protected

      ###
      ### Facade over context
      ###

      def context
        env[Startback::Context::Middleware::RACK_ENV_KEY]
      end

      def with_context(ctx = nil)
        old_context = self.context
        new_context = ctx || self.context.dup
        env[Startback::Context::Middleware::RACK_ENV_KEY] = new_context
        result = ctx ? yield : yield(new_context)
        env[Startback::Context::Middleware::RACK_ENV_KEY] = old_context
        result
      end

      ###
      ### Facade over third party tools
      ###
      include Support::OperationRunner

      def operation_world(op)
        { context: context }
      end

      ###
      ### About the body / input
      ###

      def loaded_body
        @loaded_body ||= case ctype = request.content_type
        when /json/
          json_body
        when /multipart\/form-data/
          file = params[:file]
          file_body file, Path(file[:filename]).extname
        else
          unsupported_media_type_error!(ctype)
        end
      end

      def json_body(body = request.body.read)
        JSON.load(body)
      end

      def file_body(file, ctype)
        raise UnsupportedMediaTypeError, "Unable to use `#{ctype}` as input data"
      end

      ###
      ### Various reusable responses
      ###

      def serve_nothing
        [ 204, {}, [] ]
      end

      def serve(entity_description, entity, ct = nil)
        if entity.nil?
          status 404
          content_type :json
          { description: "#{entity_description} not found" }.to_json
        elsif entity.respond_to?(:to_dto)
          ct, body = entity.to_dto(context).to(env['HTTP_ACCEPT'], ct)
          content_type ct
          body
        else
          content_type ct || "application/json"
          entity.to_json
        end
      end

    end # class Api
  end # module Web
end # module Startback
