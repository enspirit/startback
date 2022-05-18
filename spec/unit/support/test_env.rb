require 'spec_helper'
module Startback
  module Support
    describe Env do
      include Env

      before do
        ENV['FOO'] = 'BAR'
        ENV['FOOL'] = ''
        ENV['FOOLISH'] = ' BAR '
      end

      after do
        ENV.delete('FOO')
        ENV.delete('FOOL')
      end

      describe "env" do
        it 'returns an env variable' do
          expect(env('FOO')).to eql('BAR')
        end

        it 'returns nil otherwise' do
          expect(env('BAR')).to be_nil
        end

        it 'strips the value' do
          expect(env('FOOLISH')).to eql('BAR')
        end

        it 'yields the block if any' do
          expect(env('FOO'){|x| x.downcase }).to eql('bar')
        end

        it 'support a default value' do
          expect(env('BAR', 'BAZ')).to eql('BAZ')
        end

        it 'yields the block with the default if any' do
          expect(env('BAR', 'BAZ'){|x| x.downcase }).to eql('baz')
        end

        it 'returns nil when empty' do
          expect(env('FOOL')).to be_nil
        end

        it 'yields the block with the default if empty' do
          expect(env('FOOL', 'BAZ'){|x| x.downcase }).to eql('baz')
        end
      end

      describe "env!" do
        it 'returns an env variable' do
          expect(env!('FOO')).to eql('BAR')
        end

        it 'strips the value' do
          expect(env!('FOOLISH')).to eql('BAR')
        end

        it 'raise otherwise' do
          expect{ env!('BAR') }.to raise_error(Startback::Errors::Error, /BAR/)
        end

        it 'raise on empty' do
          expect{ env!('FOOL') }.to raise_error(Startback::Errors::Error, /FOOL/)
        end

        it 'yields the block if any' do
          expect(env('FOO'){|x| x.downcase }).to eql('bar')
        end
      end
    end
  end
end
