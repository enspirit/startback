require 'spec_helper'

module Startback
  module Support
    describe DataObject do

      class FooDataObject
        include DataObject
      end

      let(:data) do
        {
          :foo => 'bar',
          'bar' => 'baz'
        }
      end

      subject do
        FooDataObject.new(data)
      end

      it 'lets create an instance with providing data' do
        expect(subject).to be_a(FooDataObject)
      end

      it 'lets get the data back' do
        expect(subject.to_data).to eql(data)
        expect(subject.to_data).not_to be(data)
      end

      it 'lets to_json it' do
        expect(subject.to_json).to eql(%Q{{"foo":"bar","bar":"baz"}})
      end

      describe "data helpers" do
        it 'lets access data through methods' do
          expect(subject.foo).to eql('bar')
        end

        it 'is indifferent to symbol vs. string' do
          expect(subject.bar).to eql('baz')
        end

        it 'is indifferent to camel casing' do
          expect(subject.bar).to eql('baz')
        end

        it 'raises a NoMethodError when not known' do
          expect {
            subject.no_such_one
          }.to raise_error(NoMethodError)
        end

        it 'implements respond_to? correctly' do
          expect(subject.respond_to?(:foo)).to eql(true)
          expect(subject.respond_to?(:bar)).to eql(true)
          expect(subject.respond_to?(:no_such_one)).to eql(false)
        end
      end # data helpers

      describe "? helpers" do
        let(:data) do
          {
            'some' => 'thing',
            'ready' => false,
            'unready' => true,
            'nothing' => nil
          }
        end

        it 'works as expected' do
          expect(subject.some?).to eql(true)
          expect(subject.ready?).to eql(false)
          expect(subject.unready?).to eql(true)
          expect(subject.nothing?).to eql(false)
        end

        it 'implements respond_to? correctly' do
          expect(subject.respond_to?(:some?)).to eql(true)
          expect(subject.respond_to?(:ready?)).to eql(true)
          expect(subject.respond_to?(:unready?)).to eql(true)
          expect(subject.respond_to?(:nothing?)).to eql(true)
        end

        it 'stays conservative' do
          expect {
            subject.no_such_one?
          }.to raise_error(NoMethodError)
          expect(subject.respond_to?(:no_such_one?)).to eql(false)
        end
      end

      describe "case helpers" do
        let(:data) do
          {
            'camelCase' => 'snake_case'
          }
        end

        it 'lets use camelCase' do
          expect(subject.camelCase).to eql('snake_case')
        end

        it 'lets use camel_case' do
          expect(subject.camel_case).to eql('snake_case')
        end

        it 'implements respond_to? correctly' do
          expect(subject.respond_to?(:camelCase)).to eql(true)
          expect(subject.respond_to?(:camel_case)).to eql(true)
        end

        it 'is compatible with ? helpers' do
          expect(subject.camelCase?).to eql(true)
          expect(subject.camel_case?).to eql(true)
        end

        it 'stays conservative' do
          expect {
            subject.no_such_one
          }.to raise_error(NoMethodError)
          expect(subject.respond_to?(:no_such_one)).to eql(false)
          expect(subject.respond_to?(:no_such_one?)).to eql(false)
        end
      end

      describe '[]' do
        let(:data) do
          {
            :foo => 'bar',
            'bar' => 'baz',
            'camelCase' => 'snake_case'
          }
        end

        it 'lets access data' do
          expect(subject[:foo]).to eql('bar')
          expect(subject['bar']).to eql('baz')
          expect(subject['camelCase']).to eql('snake_case')
        end

        it 'uses indifferent access' do
          expect(subject['foo']).to eql('bar')
          expect(subject[:bar]).to eql('baz')
          expect(subject[:camelCase]).to eql('snake_case')
        end

        it 'has no other magic and returns nil in all other cases' do
          expect(subject[:foo?]).to be_nil
          expect(subject[:camel_case]).to be_nil
          expect(subject[:camel_case?]).to be_nil
        end
      end
    end
  end
end
