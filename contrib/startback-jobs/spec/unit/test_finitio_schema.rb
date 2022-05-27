require 'spec_helper'

module Startback
  module Jobs
    describe 'Finitio schemas' do

      it 'is correctly installed on stdlib' do
        system = Finitio.system <<~FIO
          @import startback/jobs

          Job.Ref
        FIO
        expect {
          system.dress({ id: "hello" })
        }.not_to raise_error
      end

    end
  end
end
