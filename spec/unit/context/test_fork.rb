require 'spec_helper'

module Startback
  describe Context, "fork" do

    it 'is a simple dup without args' do
      context = SubContext.new
      context.foo = ['hello']

      forked = context.fork
      puts "Forked: #{forked.inspect}"
      expect(fork).not_to be(context)
      expect(forked.foo).to eql(['hello'])
      expect(forked.foo).to be(context.foo)
    end

    it 'yields the context if a block is provided' do
      context = SubContext.new

      seen = false
      context.fork({ 'foo' => 'hello' }) do |forked|
        expect(fork).not_to be(context)
        expect(forked.foo).to eql('hello')
        seen = true
      end
      expect(seen).to eql(true)
    end

    it 'uses the factory on the hash provided' do
      context = SubContext.new

      forked = context.fork({ 'foo' => 'hello' })
      expect(fork).not_to be(context)
      expect(forked.foo).to eql('hello')
    end

  end
end
