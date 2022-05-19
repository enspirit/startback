require 'spec_helper'

module Startback
  class Context

    class MyContextSubClass < Context
    end

    describe Middleware do
      include Rack::Test::Methods

      def app
        build_args = self.build_args
        Rack::Builder.new do
          use Middleware, *build_args
          run ->(env){
            ctx = env[Startback::Context::Middleware::RACK_ENV_KEY]
            [200, {}, ctx.class.to_s]
          }
        end
      end

      context 'when used without context' do
        let(:build_args){ [] }

        it 'sets the default context class' do
          get '/'
          expect(last_response.status).to eql(200)
          expect(last_response.body).to eql("Startback::Context")
        end
      end

      context 'when specifying the context class' do
        let(:build_args){ [MyContextSubClass.new] }

        it 'sets the default context class' do
          get '/'
          expect(last_response.status).to eql(200)
          expect(last_response.body).to eql("Startback::Context::MyContextSubClass")
        end
      end

    end
  end # module Web
end # module Startback
