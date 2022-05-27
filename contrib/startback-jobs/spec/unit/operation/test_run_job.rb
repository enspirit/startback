require 'spec_helper'

module Startback
  module Jobs
    describe RunJob do

      let(:job_data) do
        a_job_data
      end

      let(:jobs_relvar) do
        Bmg.mutable([job_data])
      end

      let(:context) do
        Context.new.with_world(startback_jobs: jobs_relvar)
      end

      subject do
        RunJob.new(id: 'abcdef').bind({
          context: context,
        }).call
      end

      it 'runs the job' do
        expect(subject).to eql('Hello !!')
      end

      it 'updates the job' do
        subject
        job_info = jobs_relvar.one
        expect(job_info[:opResult]).to eql('Hello !!')
        expect(job_info[:isReady]).to eql(true)
      end
    end
  end
end
