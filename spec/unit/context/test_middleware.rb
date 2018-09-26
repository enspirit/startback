require 'spec_helper'

module Startback
  class Context

    class MyContextSubClass < Context
    end

    describe Middleware do
      include Rack::Test::Methods

      def app
        opts = middleware_options
        Rack::Builder.new do
          use Middleware, opts
          run ->(env){
            ctx = env[Startback::Context::Middleware::RACK_ENV_KEY] 
            [200, {}, ctx.class.to_s]
          }
        end
      end

      context 'when used without option' do
        let(:middleware_options){ nil }

        it 'sets the default context class' do
          get '/'
          expect(last_response.status).to eql(200)
          expect(last_response.body).to eql("Startback::Context")
        end
      end

      context 'when specifying the context class' do
        let(:middleware_options){{
          context_class: MyContextSubClass
        }}

        it 'sets the default context class' do
          get '/'
          expect(last_response.status).to eql(200)
          expect(last_response.body).to eql("Startback::Context::MyContextSubClass")
        end
      end

    end
  end # module Web
end # module Startback
