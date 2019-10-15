require 'spec_helper'
require 'singleton'
module Startback
  module Support
    describe OperationRunner, "before_call" do

      class OperationTestBeforeCall < Operation

        def initialize
          before_called = false
        end
        attr_accessor :before_called

        before_call do
          self.before_called = true
        end

        def call
          {
            seen_hello: "world"
          }
        end

      end

      let(:op) {
        OperationTestBeforeCall.new
      }

      class RunnerTest1
        include OperationRunner

        def operation_world(op)
          { hello: "world" }
        end
      end

      it 'runs before the around hooks' do
        expect(RunnerTest1.new.run(op)).to eql({
          seen_hello: "world"
        })
        expect(op.before_called).to eql(true)
      end


    end
  end
end