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

      ###
      ### Facade over third party tools
      ###

      def run(operation)
        operation
          .bind({ context: context })
          .call
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

      def serve(entity_description, entity, ct = :json)
        if entity.nil?
          status 404
          content_type :json
          { description: "#{entity_description} not found" }.to_json
        else
          content_type ct
          entity.to_json
        end
      end

    end # class Api
  end # module Web
end # module Startback
