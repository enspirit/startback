require 'spec_helper'
require 'startback/web/magic_assets'
require 'startback/web/magic_assets/ng_html_transformer'

module Startback
  module Web
    describe MagicAssets do
      include Rack::Test::Methods

      context 'when used as an app' do
        let(:app){
          MagicAssets.new({
            folder: Path.dir/"fixtures/assets"
          })
        }

        it 'works as expected' do
          get "/index.js"
          expect(last_response.status).to eql(200)
          expect(last_response.body).to match(/function test/)
        end

        it 'delegates a [] call to sprockets' do
          result = app['index.js']
          expect(result.to_s).to match(/function test/)
        end

        it 'returns a 404 on unknown' do
          get '/nosuchone.js'
          expect(last_response.status).to eql(404)
        end
      end

      context 'when used as a middleware' do
        let(:app){
          Rack::Builder.new do
            use MagicAssets, {
              folder: Path.dir/"fixtures/assets",
              path: "/my-assets"
            }
            run ->(t){
              [200, {}, ["Hello world"]]
            }
          end
        }

        it 'lets unrelated things pass' do
          get "/hello"
          expect(last_response.status).to eql(200)
          expect(last_response.body).to eql("Hello world")
        end

        it 'serves the assets under the chosen path' do
          get "/my-assets/index.js"
          expect(last_response.status).to eql(200)
          expect(last_response.body).to match(/function test/)
        end
      end

      context 'when registering the NgHtmlTransformer' do
        let(:app){
          plugin = MagicAssets::NgHtmlTransformer.new({
            ng_module: "test.templates"
          })
          MagicAssets.new({
            folder: Path.dir/"fixtures/assets",
            plugins: [plugin]
          })
        }

        it 'works as expected' do
          get "/index.js"
          expect(last_response.status).to eql(200)
          expect(last_response.body).to match(/function test/)
          expect(last_response.body).to match(/Hello \{\{who\}\}/)
          expect(last_response.body).to match(/angular.module\("test.templates"\)/)
        end
      end

    end
  end
end
