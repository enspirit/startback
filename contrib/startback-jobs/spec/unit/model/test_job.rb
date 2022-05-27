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
      end
    end
  end
end
