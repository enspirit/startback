module Startback
  module Web
    class Api < Sinatra::Base
      include Support

      set :raise_errors, true
      set :show_exceptions, false

    protected

      ###
      ### Facade over context
      ###

      def context
        env['GYRB_CONTEXT']
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
          file_body params[:file], Path(file[:filename]).extname
        else
          unsupported_content_type(ctype)
        end
      end

      def json_body(body = request.body.read)
        JSON.load(body)
      end

      def file_body(file, ctype)
        unsupported_content_type(ctype)
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

      ###
      ### Easier error handling for sub classes
      ###

      def user_error(msg)
        raise UserError, msg
      end

      def server_error(msg)
        raise ServerError, msg
      end

      def unsupported_content_type(type)
        raise UnsupportedContentTypeError, "Unable to use `#{type}` as input data"
      end

    end # class Api
  end # module Web
end # module Startback
