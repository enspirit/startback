module Startback
  module Errors

    class Error < StandardError
      def initialize(message = nil, causes = nil)
        super(message)
        @causes = Array(causes)
      end
      attr_reader :causes

      class << self
        def status(code = nil)
          if code.nil?
            @code || (superclass.respond_to?(:status) ? superclass.status : 500)
          else
            @code = code || @code
          end
        end

        def keep_error(keep = nil)
          @keep_error = keep unless keep.nil?
          @keep_error
        end
      end

      def message
        msg = super
        return msg unless msg == self.class.name
        parts = self.class.name.split('::').last.gsub(/[A-Z]/){|x|
          " #{x.downcase}"
        }.strip.split(" ")
        parts = parts[0...-1] unless self.class.keep_error
        parts.join(" ").capitalize
      end

      def has_causes?
        causes && !causes.empty?
      end

      def cause
        causes&.first
      end
    end

    class BadRequestError < Error
      status 400
    end

      class UnauthorizedError < BadRequestError
        status 401
      end

      class ForbiddenError < BadRequestError
        status 403
      end

      class NotFoundError < BadRequestError
        status 404
      end

      class MethodNotAllowedError < BadRequestError
        status 405
      end

      class NotAcceptableError < BadRequestError
        status 406
      end

      class ConflictError < BadRequestError
        status 409
      end

      class GoneError < BadRequestError
        status 410
      end

      class PreconditionFailedError < BadRequestError
        status 412
      end

      class UnsupportedMediaTypeError < BadRequestError
        status 415
      end

      class ExpectationFailedError < BadRequestError
        status 417
      end

      class LockedError < BadRequestError
        status 423
      end

      class PreconditionRequiredError < BadRequestError
        status 428
      end

    class InternalServerError < Error
      status 500
      keep_error(true)
    end

      class NotImplementedError < InternalServerError
        status 501
      end

    ### Helper methods

      def bad_request_error!(msg = nil)
        raise Startback::Errors::BadRequestError, msg
      end
      module_function :bad_request_error!

      def unauthorized_error!(msg = nil)
        raise Startback::Errors::UnauthorizedError, msg
      end
      module_function :unauthorized_error!

      def forbidden_error!(msg = nil)
        raise Startback::Errors::ForbiddenError, msg
      end
      module_function :forbidden_error!

      def not_found_error!(msg = nil)
        raise Startback::Errors::NotFoundError, "#{msg} not found"
      end
      module_function :not_found_error!

      def method_not_allowed_error!(msg = nil)
        raise Startback::Errors::MethodNotAllowedError, msg
      end
      module_function :method_not_allowed_error!

      def not_acceptable_error!(msg = nil)
        raise Startback::Errors::NotAcceptableError, msg
      end
      module_function :not_acceptable_error!

      def conflict_error!(msg = nil)
        raise Startback::Errors::ConflictError, msg
      end
      module_function :conflict_error!

      def gone_error!(msg = nil)
        raise Startback::Errors::GoneError, msg
      end
      module_function :gone_error!

      def precondition_failed_error!(msg = nil)
        raise Startback::Errors::PreconditionFailedError, msg
      end
      module_function :precondition_failed_error!

      def unsupported_media_type_error!(media)
        raise Startback::Errors::UnsupportedMediaTypeError, "Unable to use `#{media}` as input data"
      end
      module_function :unsupported_media_type_error!

      def expectation_failed_error!(msg = nil)
        raise Startback::Errors::ExpectationFailedError, msg
      end
      module_function :expectation_failed_error!

      def locked_error!(msg = nil)
        raise Startback::Errors::LockedError, msg
      end
      module_function :locked_error!

      def precondition_required_error!(msg = nil)
        raise Startback::Errors::PreconditionRequiredError, msg
      end
      module_function :precondition_required_error!

      def internal_server_error!(msg = nil)
        raise Startback::Errors::InternalServerError, msg
      end
      module_function :internal_server_error!

      def not_implemented_error!(msg = nil)
        raise Startback::Errors::NotImplementedError, msg
      end
      module_function :not_implemented_error!

  # Aliases

      def user_error!(msg = nil)
        raise Startback::Errors::BadRequestError, msg
      end
      module_function :user_error!

      def server_error!(msg = nil)
        raise Startback::Errors::InternalServerError, msg
      end
      module_function :server_error!

  end # module Errors
  include Errors
end # module Startback
