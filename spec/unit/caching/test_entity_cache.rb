require 'spec_helper'
require 'startback/caching'
module Startback
  module Caching
    describe EntityCache do

      class BaseCache < EntityCache

        def initialize(options = {})
          super(Store.new, context, options)
          @called = 0
          @last_key = nil
        end
        attr_reader :called, :last_key

      protected

        def primary_key(ckey)
          case ckey
          when Integer then "a key"
          when String then ckey
          else
            raise "Invalid key `#{ckey}`"
          end
        end

        # We use the deprecated methods below to test
        # backward compatibility with 0.5.0.

        def full_key(key)
          { k: key }
        end

        def load_raw_data(key)
          @called += 1
          @last_key = key
          "a value"
        end

      end

      class ShortCache < BaseCache
        self.default_ttl = 1
      end

      class InvalidatingCache < BaseCache

      protected

        def valid?(key, value)
          false
        end

      end

      let(:cache) {
        BaseCache.new
      }

      describe "default_ttl" do

        it 'has a default ttl of one hour' do
          expect(BaseCache.default_ttl).to eql(3600)
        end

        it 'allows overriding it' do
          expect(ShortCache.default_ttl).to eql(1)
        end

        it 'is accessible as default_caching_options on the instance' do
          expect(cache.send(:default_caching_options)).to eql({ttl: 3600})
        end

      end

      describe "get" do

        subject do
          cache.get("a key")
        end

        it 'yields to load_raw_data only once with the short key' do
          expect(subject).to eql("a value")
          expect(subject).to eql("a value")
          expect(cache.called).to eql(1)
          expect(cache.last_key).to eql("a key")
        end

        it 'raises when an error occurs' do
          expect_any_instance_of(Store).to receive(:exist?).and_raise("Cache failed")
          expect {
            subject
          }.to raise_error(/Cache failed/)
        end

      end

      describe "primary_key" do

        subject{
          cache.get(12)
        }

        it 'allows using candidate keys' do
          expect(subject).to eql("a value")
          expect(subject).to eql("a value")
          expect(cache.called).to eql(1)
          expect(cache.last_key).to eql("a key")
        end

      end

      describe "invalidate" do

        it 'strips the key on the store, yielding a cache miss' do
          expect(cache.get("a key")).to eql("a value")
          cache.invalidate("a key")
          expect(cache.get("a key")).to eql("a value")
          expect(cache.called).to eql(2)
          expect(cache.last_key).to eql("a key")
        end

      end

      describe "valid? override" do

        let(:cache) {
          InvalidatingCache.new
        }

        it 'yields to load_raw_data only once with the extend key' do
          expect(cache.get("a key")).to eql("a value")
          expect(cache.get("a key")).to eql("a value")
          expect(cache.called).to eql(2)
          expect(cache.last_key).to eql("a key")
        end

      end

      describe 'when disabling error raising' do
        let(:cache) do
          BaseCache.new(:raise_on_cache_fail => false)
        end

        subject do
          cache.get("a key")
        end

        it 'yields to load_raw_data only once with the short key' do
          expect(subject).to eql("a value")
        end

        it 'does not raise when an error occurs' do
          expect_any_instance_of(Store).to receive(:exist?).and_raise("Cache failed")
          expect_any_instance_of(Caching::Logger).to receive(:cache_fail)
          expect(subject).to eql("a value")
        end
      end

      describe "with prometheus listener too" do

        let(:listener) do
          Caching::Prometheus.new
        end

        let(:cache) do
          BaseCache.new.send(:register, listener)
        end

        before do
          expect(listener).to receive(:cache_miss)
          expect(listener).to receive(:cache_hit)
        end

        it 'yields to load_raw_data only once with the extend key' do
          expect(cache.get("a key")).to eql("a value")
          expect(cache.get("a key")).to eql("a value")
        end

      end

    end
  end
end
