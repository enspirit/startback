require 'spec_helper'

module Startback
  module Audit
    describe Tracer do

      let(:spans_seen) do
        []
      end

      subject do
        Tracer.new.on_span do |span|
          spans_seen << span
        end
      end

      it 'clones the object on attach_to' do
        expect(subject).not_to be_attached
        attached = subject.attach_to('the-trace', 'root-span')
        expect(attached).to be_a(Tracer)
        expect(attached).not_to be(subject)
        expect(attached).to be_attached
        expect(subject).not_to be_attached
      end

      describe 'fork' do
        it 'fails if not attached' do
          expect(subject).not_to be_attached
          expect {
            subject.fork do
              12
            end
          }.to raise_error(/attached/)
        end

        it 'returns the block result' do
          attached = subject.attach_to('the-trace', 'root-span')
          result = attached.fork do
            'foo'
          end
          expect(result).to eql('foo')
        end

        it 'propagates spans to listeners' do
          attached = subject.attach_to('the-trace', 'root-span')
          result = attached.fork do
            'foo'
          end
          expect(spans_seen.size).to eql(2)
          expect(spans_seen.last).to be_a(Span)
          expect(spans_seen.last.timing).not_to be_nil
          expect(spans_seen.last).to be_finished
          expect(spans_seen.last).to be_success
          expect(spans_seen.last).not_to be_error
        end

        it 'reraises any error that occurs' do
          attached = subject.attach_to('the-trace', 'root-span')
          expect {
            attached.fork do
              raise ArgumentError, "An error"
            end
          }.to raise_error(ArgumentError)
        end

        it 'traces any error that occurs' do
          attached = subject.attach_to('the-trace', 'root-span')
          expect {
            attached.fork do
              raise ArgumentError, "An error"
            end
          }.to raise_error(ArgumentError)
          expect(spans_seen.size).to eql(2)
          expect(spans_seen.last).to be_a(Span)
          expect(spans_seen.last.timing).not_to be_nil
          expect(spans_seen.last).to be_finished
          expect(spans_seen.last).not_to be_success
          expect(spans_seen.last).to be_error
          expect(spans_seen.last.error).to be_a(ArgumentError)
        end
      end

      describe 'redacting' do
        it 'applies by default' do
          attached = subject.attach_to('the-trace', 'root-span')
          result = attached.fork({
            foo: 'bar',
            password: 'baz',
            repeatPassword: 'baz'
          }) do
            'foo'
          end
          expect(spans_seen.size).to eql(2)
          expect(spans_seen.last).to be_a(Span)
          expect(spans_seen.last.attributes).to eql({
            foo: 'bar',
            password: '---redacted---',
            repeatPassword: '---redacted---'
          })
        end
      end

    end
  end
end

