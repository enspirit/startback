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
    end
  end # module Web
end # module Startback
