require 'spec_helper'

module Startback
  module Audit
    describe Middleware do
      include Rack::Test::Methods

      def app
        Rack::Builder.new do
          use Startback::Context::Middleware
          use Middleware
          run ->(env) {
            ctx = env[Startback::Context::Middleware::RACK_ENV_KEY]
            attached = ctx.tracer.attached?
            last_span = ctx.tracer.last_span!
            [200, {
              'tracer-attached' => attached,
              'last-span' => last_span
            }, 'ok']
          }
        end
      end

      context 'when not provided with tracing headers' do
        it 'starts a new trace' do
          get '/'
          expect(last_response.status).to eql(200)
          expect(last_response.headers['tracer-attached']).to eq(true)
          expect(last_response.body).to eql("ok")
        end

        it 'creates a fresh new span' do
          get '/'
          expect(last_response.status).to eql(200)
          expect(last_response.headers['last-span']).not_to be_nil
          expect(last_response.body).to eql("ok")
        end
      end

      context 'when provided with tracing headers' do
        it 'does attach the tracer' do
          header('X-Trace-Id', 'trace-id')
          header('X-Span-Id', 'span-id')
          get '/'
          expect(last_response.status).to eql(200)
          expect(last_response.headers['tracer-attached']).to eq(true)
          expect(last_response.body).to eql("ok")
        end

        it 'does create a new span' do
          header('X-Trace-Id', 'trace-id')
          header('X-Span-Id', 'span-id')
          get '/'
          expect(last_response.status).to eql(200)

          span = last_response.headers['last-span']
          expect(span).not_to be_nil
          expect(span.trace_id).to eq('trace-id')
          expect(span.parent_id).to eq('span-id')
          expect(span.span_id).not_to be_nil
          expect(span.span_id).not_to eq('span-id')
        end
      end
    end # describe Middleware
  end # module Audit
end # module Startback
