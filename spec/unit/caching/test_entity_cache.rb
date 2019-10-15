require 'spec_helper'
require 'startback/caching/entity_cache'
require 'startback/caching/store'
module Startback
  module Caching
    describe EntityCache do

      class BaseCache < EntityCache

        def initialize(context = nil)
          super(Store.new, context)
          @called = 0
          @last_key = nil
        end
        attr_reader :called, :last_key

      protected

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

        subject{
          cache.get("a key")
        }

        it 'yields to load_raw_data only once with the short key' do
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

    end
  end
end
