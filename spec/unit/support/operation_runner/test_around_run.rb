require 'spec_helper'
require 'singleton'
module Startback
  module Support
    describe OperationRunner, "around_run" do

      class OperationTest < Startback::Operation

        def call
          { seen_hello: hello }
        end

      end

      let(:op) {
        OperationTest.new
      }

      context 'the simplest contract' do
        class RunnerTest1
          include OperationRunner

          def operation_world(op)
            { hello: "world"}
          end
        end

        it 'lets run an operation with world bound' do
          expect(RunnerTest1.new.run(op)).to eql({
            seen_hello: "world"
          })
        end
      end

      context 'the around feature' do
        class RunnerTest2
          include OperationRunner

          def initialize
            @arounds = []
          end
          attr_reader :arounds

          around_run do |o, then_block|
            raise unless o.is_a?(OperationTest)
            arounds << "hello"
            then_block.call
          end

          around_run do |_, then_block|
            arounds << "world"
            then_block.call
          end

          def operation_world(op)
            { hello: "world" }
          end
        end

        it 'calls the around before the operation itself' do
          test = RunnerTest2.new
          got = test.run(op)
          expect(test.arounds).to eql(["hello", "world"])
          expect(got).to eql({
            seen_hello: "world"
          })
        end
      end

      context 'the around feature with a class' do
        class SomeTransactionManager
          include Singleton

          def initialize
            @called = false
          end
          attr_reader :called

          def call(runner, op)
            raise unless runner.is_a?(RunnerTest3)
            raise unless op.is_a?(OperationTest)
            @called = true
            yield
          end

        end

        class RunnerTest3
          include OperationRunner
          around_run SomeTransactionManager.instance

          def operation_world(op)
            { hello: "world" }
          end
        end

        it 'calls the proc with expected parameters' do
          test = RunnerTest3.new
          got = test.run(op)
          expect(SomeTransactionManager.instance.called).to eql(true)
          expect(got).to eql({
            seen_hello: "world"
          })
        end
      end

      context 'the around feature with a subclass' do
        class RunnerTest4
          include OperationRunner

          def initialize
            @called = false
          end
          attr_reader :called

          around_run do |o,t|
            raise unless o.is_a?(OperationTest)
            @called = true
            t.call
          end
        end

        class RunnerTest5 < RunnerTest4

          def initialize
            super
            @subcalled = false
          end
          attr_reader :subcalled

          around_run do |o,t|
            raise unless o.is_a?(OperationTest)
            @subcalled = true
            t.call
          end

          def operation_world(op)
            { hello: "world" }
          end
        end

        it 'executes all hooks' do
          test = RunnerTest5.new
          got = test.run(op)
          expect(test.called).to be(true)
          expect(test.subcalled).to be(true)
          expect(got).to eql({
            seen_hello: "world"
          })
        end

      end

    end # module OperationRunner
  end # module Support
end # module Startback
