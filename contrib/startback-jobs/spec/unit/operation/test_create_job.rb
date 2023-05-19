require 'spec_helper'

module Startback
  module Jobs
    describe CreateJob do

      let(:request) do
        {
          isReady: false,
          opClass: 'CowSay',
          opInput: {},
          createdBy: 'blambeau',
        }
      end

      let(:jobs_relvar) do
        Bmg.mutable([])
      end

      let(:context) do
        Context.new.with_world(startback_jobs: jobs_relvar)
      end

      subject do
        CreateJob.new(request).bind({
          context: context,
        }).call
      end

      it 'creates a job' do
        expect(subject).to be_a(Model::Job)
        expect(subject.id).not_to be_nil
      end

      it 'inserts the job in the relvar' do
        subject
        expect(jobs_relvar.count).to eql(1)
      end
    end
  end
end
