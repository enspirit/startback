module Startback
  module Web
    class MagicAssets
      #
      # Plugin for MagicAssets that compiles .html angular templates in the
      # assets structure to javascript files filling angular's template cache.
      #
      # Heavily inspired, yet over-simplified version, of angular-rails-templates
      # See https://github.com/pitr/angular-rails-templates, licensed under MIT
      #
      # Example:
      #
      #   use Startback::Web::MagicAssets, {
      #     plugins: [Startback::Web::MagicAssets::NgHtmlTransfomer.new]
      #   }
      #
      class NgHtmlTransformer

        DEFAULT_OPTIONS = {
          :path       => '/assets',
          :ng_module  => 'templates',
          :mime_type  => 'text/ng-html',
          :extensions => [".html"]
        }

        def initialize(options = {})
          @options = DEFAULT_OPTIONS.merge(options)
        end
        attr_reader :options

        def install(sprockets)
          sprockets.register_mime_type options[:mime_type], extensions: options[:extensions]
          sprockets.register_transformer options[:mime_type], 'application/javascript', self
        end

TPL = <<-EOF
angular.module("<%= ng_module %>").run(["$templateCache", function($templateCache) {
  $templateCache.put("<%= angular_template_name %>", <%= html %>)
}]);
EOF

        # inspired by Rails' action_view/helpers/javascript_helper.rb
        JS_ESCAPE_MAP = {
          '\\'    => '\\\\',
          "\r\n"  => '\n',
          "\n"    => '\n',
          "\r"    => '\n',
          '"'     => '\\"',
          "'"     => "\\'"
        }

        # We want to deliver the shortist valid javascript escaped string
        # Count the number of " vs '
        # If more ', escape "
        # If more ", escape '
        # If equal, prefer to escape "

        def escape_javascript(raw)
          if raw
            quote = raw.count(%{'}) >= raw.count(%{"}) ? %{"} : %{'}
            escaped = raw.gsub(/(\\|\r\n|[\n\r#{quote}])/u) {|match| JS_ESCAPE_MAP[match] }
            "#{quote}#{escaped}#{quote}"
          else
            '""'
          end
        end

        def call(input)
          file_path = input[:filename]
          angular_template_name = "#{options[:path]}/#{input[:name]}.html"
          source_file = file_path
          ng_module = options[:ng_module]
          html = escape_javascript(input[:data].chomp)
          ERB.new(TPL).result(binding)
        end

      end # class NgHtmlTransformer
    end # class MagicAssets
  end # module Web
end # module Startback
