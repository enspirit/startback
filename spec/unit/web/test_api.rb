require 'spec_helper'
require 'startback/web/api'

module Startback
  module Web
    describe Api do
      include Rack::Test::Methods

      class JsonDto
        def to(accept, content_type)
          ["application/json", %Q{{"foo":"bar"}}]
        end
      end

      class PathDto
        def to(accept, content_type)
          ["text/plain", Path.file]
        end
      end

      class DtoAble
        def initialize(dto)
          @dto = dto
        end
        def to_dto(context)
          @dto
        end
      end

      class TestedApi < ::Startback::Web::Api
        get '/no-such-one' do
          serve("Something", nil)
        end

        get '/entity' do
          serve('Entity', {foo: "bar"})
        end

        get '/path' do
          serve('Path', Path.file)
        end

        get '/dto-able' do
          serve('DTO', DtoAble.new(JsonDto.new))
        end

        get '/dto-path' do
          serve('DTO', DtoAble.new(PathDto.new))
        end

        post '/json-body' do
          content_type :json
          json_body.to_json
        end
      end

      let(:app) {
        TestedApi
      }

      it 'convert nil to 404' do
        get '/no-such-one'
        expect(last_response.status).to eql(404)
      end

      it 'supports serving entities' do
        get '/entity'
        expect(last_response.body).to eql(%Q{{"foo":"bar"}})
      end

      it 'supports serving paths' do
        get '/path'
        expect(last_response.body).to eql(Path.file.read)
      end

      it 'supports serving DTO-able objects' do
        get '/dto-able'
        expect(last_response.body).to eql(%Q{{"foo":"bar"}})
      end

      it 'supports serving DTO-able objects eventually returning paths' do
        get '/dto-path'
        expect(last_response.body).to eql(Path.file.read)
      end

      describe 'json_body' do
        let(:json) {
          %Q{{"todos":[{"id":1}],"done":true}}
        }

        it 'reads a json body' do
          post '/json-body', json, { 'CONTENT_TYPE' => 'application/json' }
          expect(last_response.body).to eql(json)
        end

        it 'reads a json body sent as text' do
          post '/json-body', json, { 'CONTENT_TYPE' => 'text/plain' }
          expect(last_response.body).to eql(json)
        end

        # Rack parses the body as form data in the next two cases, and Rack 3
        # no longer rewinds it afterwards.

        it 'reads a json body sent as a form' do
          post '/json-body', json, { 'CONTENT_TYPE' => 'application/x-www-form-urlencoded' }
          expect(last_response.body).to eql(json)
        end

        it 'reads a json body sent without any content type' do
          # Rack::Test would default to urlencoded
          env = Rack::MockRequest.env_for('/json-body', method: 'POST', input: json)
          expect(env['CONTENT_TYPE']).to be_nil

          status, _, body = app.call(env)
          expect(status).to eql(200)
          expect(body.each.to_a.join).to eql(json)
        end

        it 'still loads what it is given' do
          api = TestedApi.new!
          expect(api.send(:json_body, %Q{{"foo":"bar"}})).to eql("foo" => "bar")
        end
      end
    end
  end # module Web
end # module Startback
