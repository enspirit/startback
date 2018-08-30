module Gyrb
  module Errors

    class Error < StandardError
      class << self

        def status(code = nil)
          @code = code || @code
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

  end # module Errors
  include Errors
end # module Klaro
