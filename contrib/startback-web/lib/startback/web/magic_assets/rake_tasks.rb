module Startback
  module Web
    class MagicAssets
      class RakeTasks

        DEFAULT_OPTIONS = {
          :namespace => :assets
        }

        def initialize(rake, options)
          @rake = rake
          @options = DEFAULT_OPTIONS.merge(options)
          install
        end
        attr_reader :rake, :options

      private

        def install
          require 'securerandom'

          ns = options[:namespace]
          target_folder = options[:target]
          assets = options[:assets]
          assets = MagicAssets.new(assets) if assets.is_a?(Hash)
          version = SecureRandom.urlsafe_base64

          rake.instance_exec do
            namespace(ns) do

              desc 'Cleans generated assets'
              task :clean do
                FileUtils.rm_rf target_folder
              end

              task :prepare do
                FileUtils.mkdir_p target_folder
                (target_folder/"VERSION").write(version)
              end

              desc 'compile javascript assets'
              task :compile_js do
                assets['vendor.js'].write_to(target_folder/"vendor-#{version}.min.js")
                assets['app.js'].write_to(target_folder/"app-#{version}.min.js")
                puts "successfully compiled js assets"
              end

              desc 'compile css assets'
              task :compile_css do
                assets['vendor.css'].write_to(target_folder/"vendor-#{version}.min.css")
                assets['app.css'].write_to(target_folder/"app-#{version}.min.css")
                puts "successfully compiled css assets"
              end

              desc 'compile assets'
              task :compile => [:clean, :prepare, :compile_js, :compile_css]
            end
          end
        end

      end
    end # class MagicAssets
  end # module Web
end # module Startback
