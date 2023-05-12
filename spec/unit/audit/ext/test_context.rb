require 'spec_helper'

module Startback
  module Audit
    describe "Context extension" do
      subject do
        context.to_h
      end

      context 'no tracing has been added' do
        let(:context) do
          Startback::Context.new
        end

        it 'has no tracing info' do
          expect(subject).not_to have_key('tracing')
        end

        it 'does not break reloading a context if no tracing' do
          subject = Startback::Context.h({})
          expect(subject.tracer).to be_an_instance_of(Startback::Audit::Tracer)
          expect(subject.tracer).not_to be_attached
        end
      end

      context 'some tracing has been added and attached' do
        let(:context) do
          Startback::Context.new.dup do |c|
            c.tracer = Tracer.empty.attach_to('some_trace_uuid', 'some_trace_parent_uuid')
          end
        end

        it 'has tracing info' do
          expect(subject).to have_key('tracing')
          expect(subject['tracing']['trace_id']).to eql('some_trace_uuid')
          expect(subject['tracing']['span_id']).to eql('some_trace_parent_uuid')
        end

        it 'helps reloading a tracer instance from h info' do
          subject = Startback::Context.h('tracing' => {
            'trace_id' => 'some_trace_uuid',
            'parent_id' => 'some_trace_parent_uuid'
          })
          expect(subject.tracer).to be_an_instance_of(Startback::Audit::Tracer)
          expect(subject.tracer).to be_attached
        end
      end

      context 'some tracing has been added and attached on a subclass' do
        let(:context) do
          SubContext.new.dup do |c|
            c.tracer = Tracer.empty.attach_to('some_trace_uuid', 'some_trace_parent_uuid')
          end
        end

        it 'has tracing info' do
          expect(context.tracer).to be_attached
          expect(SubContext.h_factories.size).to eql(3)
          expect(subject).to have_key('tracing')
          expect(subject['tracing']['trace_id']).to eql('some_trace_uuid')
          expect(subject['tracing']['span_id']).to eql('some_trace_parent_uuid')
        end
      end
    end
  end # module Audit
end # module Startback
