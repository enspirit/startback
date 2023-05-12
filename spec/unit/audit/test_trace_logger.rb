require 'spec_helper'

module Startback
  module Audit
    describe TraceLogger do

      let(:fake_logger) do
        Support::FakeLogger.new
      end

      let(:trace_logger) do
        TraceLogger.new(fake_logger)
      end

      let(:tracer) do
        Tracer.new.on_span(trace_logger)
      end

      it 'helps logging successes' do
        attached = tracer.attach_to('trace', 'root-span')
        attached.fork(foo: 'bar') do
          "hello world"
        end
        expect(fake_logger.seen.size).to eql(2)
        expect(fake_logger.seen.first).to match(/DEBUG/)
        expect(fake_logger.seen.last).to match(/INFO/)
      end

      it 'helps logging user errors' do
        attached = tracer.attach_to('trace', 'root-span')
        attached.fork(foo: 'bar') do
          raise Startback::Errors::ForbiddenError, "no such access granted"
        end rescue nil
        expect(fake_logger.seen.size).to eql(2)
        expect(fake_logger.seen.first).to match(/DEBUG/)
        expect(fake_logger.seen.last).to match(/WARN/)
      end

      it 'helps logging fatal errors' do
        attached = tracer.attach_to('trace', 'root-span')
        attached.fork(foo: 'bar') do
          raise ArgumentError, "something bad"
        end rescue nil
        expect(fake_logger.seen.size).to eql(2)
        expect(fake_logger.seen.first).to match(/DEBUG/)
        expect(fake_logger.seen.last).to match(/ERROR/)
      end

    end
  end
end
