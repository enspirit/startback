require 'spec_helper'
require 'startback/audit'
module Startback
  module Audit
    describe Prometheus do

      EXPORTER = Prometheus.new

      class Runner
        include Startback::Support::OperationRunner

        class IdealOp < Startback::Operation
          def call
            42
          end
        end

        class ExceptionalOp < Startback::Operation
          def call
            raise "Oops"
          end
        end

        around_run(EXPORTER)
        def test
          run IdealOp.new
        end
        def test_exp
          run ExceptionalOp.new
        end
      end

      describe 'The ideal case' do
        before do
          expect(EXPORTER.calls).to receive(:observe)
          expect(EXPORTER.errors).not_to receive(:increment)
        end
        it 'runs the operation' do
          expect(Runner.new.test).to eql(42)
        end
      end

      describe 'The exceptional case' do
        before do
          expect(EXPORTER.errors).to receive(:increment)
          expect(EXPORTER.calls).not_to receive(:observe)
        end
        it 'let errors bubble up' do
          expect { Runner.new.test_exp }.to raise_error(/Oops/)
        end
      end

    end
  end
end
