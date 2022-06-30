require 'spec_helper'

module Startback
  module Jobs
    class Model
      describe Job do
        it 'makes it easy to create an instance' do
          job = Job.new(a_job_data)
          expect(job.id).to eql('abcdef')
          expect(job[:id]).to eql('abcdef')
          expect(job.ready?).to eql(false)
        end

        it 'makes it easy to dress an instance' do
          job = Job.full(a_job_data)
          expect(job.id).to eql('abcdef')
          expect(job[:id]).to eql('abcdef')
          expect(job.ready?).to eql(false)
        end

        it 'recognizes failed jobs' do
          job = Job.full(a_job_data.merge(hasFailed: true))
          expect(job.id).to eql('abcdef')
          expect(job.failed?).to eql(true)
        end

        it 'stays compatible with jobs without the hasFailed flag' do
          job = Job.full(a_job_data.delete_if{|k| k == :hasFailed })
          expect(job.id).to eql('abcdef')
          expect(job.failed?).to eql(false)
        end
      end
    end
  end
end
