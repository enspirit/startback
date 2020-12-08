require 'prometheus/middleware/exporter'
module Startback
  module Web
    #
    # Can be used to expose the prometheus metrics inside a Startback
    # application.
    #
    # Example:
    #
    #     use Startback::Web::Prometheus
    #
    class Prometheus < Prometheus::Middleware::Exporter

    end # class Prometheus
  end # module Web
end # module Startback
