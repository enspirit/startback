require 'sprockets'
module Startback
  module Web
    #
    # Rack application & middleware that can be used to simplify javascript
    # and css assets management, using Sprockets.
    #
    # Example:
    #
    #     # Used as rack app, typically under a path
    #     Rack::Builder.new do
    #       map '/assets' do
    #         run Startback::Web::MagicAssets.new({
    #           folder: "/path/to/assets/src"
    #         })
    #       end
    #       run MyApp
    #     end
    #
    #     # Used as a rack middleware, e.g. in a Sinatra application
    #     use Startback::Web::MagicAssets, {
    #       folder: "/path/to/assets/src",
    #       path: "/assets"
    #     }
    #
    # Sprocket configuration can be done through the `:sprocket` option:
    #
    #     use Startback::Web::MagicAssets, {
    #       sprockets: {
    #         :css_compressor => :scss
    #       }
    #     }
    #
    class MagicAssets

      DEFAULT_OPTIONS = {
        sprockets: {}
      }

      def initialize(app, options = {})
        app, options = nil, app if app.is_a?(Hash)
        @app = app
        @options = DEFAULT_OPTIONS.merge(options)
        @sprockets = build_sprockets
      end
      attr_reader :sprockets

      def call(env)
        if new_env = is_match?(env)
          @sprockets.call(new_env)
        else
          @app.call(env)
        end
      end

      def [](*args, &bl)
        @sprockets.[](*args, &bl)
      end

    private

      def path
        @options[:path]
      end

      def is_match?(env)
        if @app.nil?
          # Not used as a middleware, use this env and match
          env
        elsif env['PATH_INFO'].start_with?(path)
          # Used as a middleware, and PATH_INFO starts with the
          # assets path => strip it for sprockets
          env.merge("PATH_INFO" => env["PATH_INFO"].sub(path, ""))
        else
          # No match, let @app execute with the untouched environment
          nil
        end
      end

      def build_sprockets
        Sprockets::Environment.new.tap{|s|
          Array(@options[:folder]).each do |folder|
            s.append_path(folder)
          end
          @options[:sprockets].each_pair do |k,v|
            s.public_send(:"#{k}=", v)
          end
        }
      end

    end # class MagicAssets
  end # module Web
end # module Startback
require_relative 'magic_assets/rake_tasks'
