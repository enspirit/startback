require 'spec_helper'

module Startback
  module Support
    describe World do

      let(:world) do
        World.new
      end

      describe 'with' do
        subject do
          world.with(foo: :bar, bar: :baz)
        end

        it 'returns a new world instance' do
          expect(subject).to be_a(World)
          expect(subject).not_to be(world)
        end

        it 'gives access to those variables' do
          expect(subject.foo).to eql(:bar)
          expect(subject[:bar]).to eql(:baz)
        end
      end

      describe 'dup' do
        let(:world) do
          World.new(foo: :bar)
        end

        subject do
          world.dup
        end

        it 'returns another instance' do
          expect(subject).to be_a(World)
          expect(subject).not_to be(world)
        end

        it 'keeps variables' do
          expect(subject.foo).to eql(:bar)
        end
      end

      describe 'class factory' do
        subject do
          world.factory(:foo) do
            hello
          end
        end

        def hello
          OpenStruct.new(bar: 12)
        end

        it 'returns a world instance' do
          expect(subject).to be_a(World)
          expect(subject).not_to be(world)
        end

        it 'installs the factory' do
          bound = subject.with_scope(self)
          got = bound.foo
          expect(got).to be_a(OpenStruct)
          expect(got.bar).to eql(12)
          expect(bound.foo).to be(got)
        end
      end
    end
  end
end
