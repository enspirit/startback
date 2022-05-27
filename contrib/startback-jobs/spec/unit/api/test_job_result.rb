require 'spec_helper'

module Startback
  module Jobs
    describe Api, "GET /{id}/result/" do
      include Rack::Test::Methods

      let(:job_data) do
        a_job_data(override)
      end

      let(:jobs_relvar) do
        Bmg.mutable([job_data])
      end

      let(:context) do
        Context.new.with_world(startback_jobs: jobs_relvar)
      end

      let(:app) do
        context = self.context
        Rack::Builder.new do
          use Context::Middleware, context
          run Jobs::Api
        end
      end

      let(:job_id) do
        'abcdef'
      end

      subject do
        get "/#{job_id}/result/"
      end

      context 'when the job does not exist' do
        let(:job_id) do
          "no-such-one"
        end

        let(:override) do
          {}
        end

        it 'raises' do
          expect{
            subject
          }.to raise_error(Startback::Errors::NotFoundError)
        end
      end

      context 'when the job is not ready yet' do
        let(:override) do
          {
            isReady: false,
            strategy: 'NotReady',
          }
        end

        it 'works fine' do
          res = subject
          expect(res.status).to eql(202)
          expect(res.body).to be_empty
        end
      end

      context 'when the job is ready' do
        let(:override) do
          {
            isReady: true,
            opResult: 'Hello!!',
            strategy: 'Embedded'
          }
        end

        it 'works fine' do
          res = subject
          expect(res.status).to eql(200)
          expect(res.body).to eql("Hello!!")
        end
      end

      context 'when the job is ready and has to redirect' do
        let(:override) do
          {
            isReady: true,
            strategy: 'Redirect',
            opResult: 'http://google.com',
          }
        end

        it 'works fine' do
          res = subject
          expect(res.status).to eql(301)
          expect(res['Location']).to eql("http://google.com")
        end
      end

      context 'when the job is ready and has to redirect with a 302' do
        let(:override) do
          {
            isReady: true,
            strategy: 'Redirect',
            strategyOptions: {
              'status' => 302,
              'headers' => { 'X-Mine' => 'foo' }
            },
            opResult: 'http://google.com',
          }
        end

        it 'works fine' do
          res = subject
          expect(res.status).to eql(302)
          expect(res['X-Mine']).to eql('foo')
          expect(res['Location']).to eql("http://google.com")
        end
      end
    end
  end
end
