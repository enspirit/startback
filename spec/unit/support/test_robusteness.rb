require 'spec_helper'
module Startback
  module Support
    describe Robustness do

      let(:the_logger) {
        FakeLogger.new
      }

      let(:context_with_logger) {
        Context.new.tap{|c| c.logger = the_logger }
      }

      describe "monitor" do
        include Robustness

        it 'works' do
          x = monitor("test", context_with_logger) do
            12
          end
          expect(x).to eql(12)
          expect(the_logger.last_msg.keys).to eql([:op, :op_took])
        end

      end # monitor

      describe "stop_errors" do
        include Robustness

        it 'works and logs the error' do
          x = nil
          expect {
            x = stop_errors("test", context_with_logger) do
              raise "Test"
            end
          }.not_to raise_error
          expect(x).to be(nil)
          expect(the_logger.last_msg.keys).to eql([:op, :op_took, :error])
        end

        it 'returns the result if no error' do
          x = nil
          expect {
            x = stop_errors("test", context_with_logger) do
              12
            end
          }.not_to raise_error
          expect(x).to eql(12)
          expect(the_logger.last_msg).to be_nil
        end

      end

      describe "try_max_times" do
        include Robustness

        it 'fails if n errors are seen' do
          seen = 0
          expect {
            try_max_times(2, "test", context_with_logger) do
              seen += 1
              raise "Test"
            end
          }.to raise_error("Test")
          expect(seen).to eql(2)
          expect(the_logger.last_msg.keys).to eql([:op, :op_took, :error])
        end

        it 'suceeds if an attemps succeeds' do
          seen = 0
          result = nil
          expect {
            result = try_max_times(2, "test", context_with_logger) do
              seen += 1
              raise "Test" if seen == 1
              12
            end
          }.not_to raise_error
          expect(result).to eql(12)
          expect(seen).to eql(2)
          expect(the_logger.last_msg.keys).to eql([:op, :op_took, :error])
        end

        it 'suceeds if first attemps succeeds' do
          result = nil
          expect {
            result = try_max_times(2, "test", context_with_logger) do
              12
            end
          }.not_to raise_error
          expect(result).to eql(12)
          expect(the_logger.last_msg).to be_nil
        end

      end

      describe "parse_args" do
        include Robustness::Tools

        it 'works fine with full op and no context' do
          log_msg_src = {
            op: "AnOp",
            op_data: { foo: "bar" }
          }
          log_msg, logger = parse_args(log_msg_src)
          expect(log_msg).to eql(log_msg_src)
          expect(logger).to be_a(::Logger)
        end

        it 'works fine with an string and a method name' do
          expected = {
            op: "AClass#method"
          }
          log_msg, logger = parse_args("AClass", "method")
          expect(log_msg).to eql(expected)
          expect(logger).to be_a(::Logger)
        end

        it 'works fine with an string, a method name, and a message' do
          expected = {
            op: "AClass#method",
            op_data: { message: "Hello world" }
          }
          log_msg, logger = parse_args("AClass", "method", "Hello world")
          expect(log_msg).to eql(expected)
          expect(logger).to be_a(::Logger)
        end

        it 'works fine with a string only' do
          expected = {
            op: "a message"
          }
          log_msg, logger = parse_args("a message")
          expect(log_msg).to eql(expected)
          expect(logger).to be_a(::Logger)
        end

        it 'works fine with a Exception only' do
          exception = StandardError.new('hello')
          expected = {
            error: exception
          }
          log_msg, logger = parse_args(exception)
          expect(log_msg).to eql(expected)
          expect(logger).to be_a(::Logger)
        end

        it 'works fine with a string and a context with logger' do
          expected = {
            op: "a message"
          }
          log_msg, logger = parse_args("a message", context_with_logger)
          expect(log_msg).to eql(expected)
          expect(logger).to be(the_logger)
        end

        it 'works fine with a string and an extra hash' do
          expected = {
            op: "a message",
            op_took: 16
          }
          log_msg, logger = parse_args("a message", op_took: 16)
          expect(log_msg).to eql(expected)
          expect(logger).to be_a(::Logger)
        end

        it 'works fine with a module and method' do
          expected = {
            op: "Startback#foo"
          }
          log_msg, logger = parse_args(Startback, "foo")
          expect(log_msg).to eql(expected)
          expect(logger).to be_a(::Logger)
        end

        it 'works fine with a class and method' do
          expected = {
            op: "Startback::Event#foo"
          }
          log_msg, logger = parse_args(Startback::Event, "foo")
          expect(log_msg).to eql(expected)
          expect(logger).to be_a(::Logger)
        end

        it 'works fine with an instance and method' do
          expected = {
            op: "Startback::Event#foo"
          }
          log_msg, logger = parse_args(Startback::Event.new(nil, nil), "foo")
          expect(log_msg).to eql(expected)
          expect(logger).to be_a(::Logger)
        end

        it 'when a hash is passed as last arg' do
          expected = {
            op: "hello#foo",
            op_took: 16
          }
          log_msg, logger = parse_args("hello", "foo", op_took: 16)
          expect(log_msg).to eql(expected)
          expect(logger).to be_a(::Logger)
        end
      end

      describe "logger_for" do
        include Robustness::Tools

        it 'works on a logger' do
          expect(logger_for(the_logger)).to be(the_logger)
        end

        it 'works on a Context responding to logger' do
          expect(logger_for(context_with_logger)).to be(the_logger)
        end

        it 'works on an object having a Context responding to logger' do
          x = OpenStruct.new(context: context_with_logger)
          expect(logger_for(x)).to eql(the_logger)
        end

        it 'works on an object having a Context but no logger' do
          x = OpenStruct.new(context: Context.new)
          expect(logger_for(x)).to be_a(::Logger)
        end
      end

    end
  end
end
