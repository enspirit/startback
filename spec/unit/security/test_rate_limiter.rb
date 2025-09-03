require 'spec_helper'
module Startback
  module Security
    describe RateLimiter do
      let(:limiter) do
        RateLimiter.new(options)
      end

      let(:store) {
        Caching::Store.new
      }

      let(:options) {
        {
          store: store,
          defaults: {
            strategy: :silent_drop,
            detection: 'any',
          },
        }
      }

      before(:each) do
        op_class.reset
      end

      class RateLimitedOp < Startback::Operation
        def initialize(input)
          @input = input
        end
        attr_reader :input

        def self.reset
          @called = 0
        end

        def self.called
          @called = @called + 1
        end

        def self.called_count
          @called
        end

        def call
          self.class.called
        end
      end

      def call_it_once(input = {})
        op = op_class.new(input)
        limiter.call(nil, op){ op.call }
      end

      context 'when silent_drop with a constant' do
        class ConstantRateLimitedOp < RateLimitedOp
          rate_limit({
            strategy: :silent_drop,
            detection: "constant"
          })
        end

        let (:op_class) {
          ConstantRateLimitedOp
        }

        it 'works when called once' do
          call_it_once
          expect(op_class.called_count).to eql(1)
        end

        it 'silently ignores second call' do
          call_it_once
          call_it_once
          expect(op_class.called_count).to eql(1)
        end
      end

      context 'when :fail with a constant' do
        class FailingRateLimitedOp < RateLimitedOp
          rate_limit({
            strategy: :fail,
            detection: "constant"
          })
        end

        let (:op_class) {
          FailingRateLimitedOp
        }

        it 'works when called once' do
          call_it_once
          expect(op_class.called_count).to eql(1)
        end

        it 'fails on second call' do
          call_it_once
          expect {
            call_it_once
          }.to raise_error(Startback::Errors::TooManyRequestsError)
        end
      end

      context 'when silent_drop with a symbol' do
        class InputRateLimitedOp < RateLimitedOp
          rate_limit({
            strategy: :silent_drop,
            detection: :input
          })
        end

        let (:op_class) {
          InputRateLimitedOp
        }

        context 'when called with the same input' do
          it 'works when called once' do
            call_it_once({ hello: 'foo' })
            expect(op_class.called_count).to eql(1)
          end

          it 'silently ignores second call' do
            call_it_once({ hello: 'foo' })
            call_it_once({ hello: 'foo' })
            expect(op_class.called_count).to eql(1)
          end
        end

        context 'when called with different inputs' do
          it 'accepts every call' do
            call_it_once({ hello: 'foo' })
            call_it_once({ hello: 'bar' })
            expect(op_class.called_count).to eql(2)
          end
        end
      end

      context "when the defaults options are used" do
        class DefaultsRateLimitedOp < RateLimitedOp
          rate_limit
        end

        let (:op_class) {
          DefaultsRateLimitedOp
        }

        it 'works when called once' do
          call_it_once
          expect(op_class.called_count).to eql(1)
        end

        it 'silently ignores second call' do
          call_it_once
          call_it_once
          expect(op_class.called_count).to eql(1)
        end
      end

      context 'when using the occurence option to allow more than 1 execution' do
        class OccurencesRateLimitedOp < RateLimitedOp
          rate_limit({
            strategy: :silent_drop,
            detection: "constant",
            max_occurences: 3,
          })
        end

        let (:op_class) {
          OccurencesRateLimitedOp
        }

        it 'works when called three times in a row' do
          call_it_once
          call_it_once
          call_it_once
          expect(op_class.called_count).to eql(3)
        end

        it 'silently ignores further calls' do
          call_it_once
          call_it_once
          call_it_once
          call_it_once
          call_it_once
          expect(op_class.called_count).to eql(3)
        end
      end

      context 'when using a dynamic configuration' do
        class DynamicRateLimitedOp < RateLimitedOp
          rate_limit :rate_limit_options

          def rate_limit_options
            {
              strategy: :silent_drop,
              detection: "constant",
              max_occurences: input[:max],
            }
          end
        end

        let (:op_class) {
          DynamicRateLimitedOp
        }

        it 'works when called three times in a row' do
          call_it_once(max: 2)
          call_it_once(max: 2)
          call_it_once(max: 2)
          expect(op_class.called_count).to eql(2)
        end
      end
    end
  end
end
