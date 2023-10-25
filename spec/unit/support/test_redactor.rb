require 'spec_helper'

module Startback
  module Support
    describe Redactor do

      let(:redactor) do
        Redactor.new
      end

      it 'applies default blacklists for security reasons' do
        data = {
          token: "will not be dumped",
          a_token: "will not be dumped",
          AToken: "will not be dumped",
          password: "will not be dumped",
          secret: "will not be dumped",
          credentials: "will not be dumped",
          foo: "bar"
        }
        expect(redactor.redact(data)).to eql({
          token: "---redacted---",
          a_token: "---redacted---",
          AToken: "---redacted---",
          password: "---redacted---",
          secret: "---redacted---",
          credentials: "---redacted---",
          foo: "bar",
        })
      end

      it 'applies default blacklists to data arrays too' do
        data = [{
          token: "will not be dumped",
          a_token: "will not be dumped",
          AToken: "will not be dumped",
          password: "will not be dumped",
          secret: "will not be dumped",
          credentials: "will not be dumped",
          foo: "bar"
        }]
        expect(redactor.redact(data)).to eql([{
          token: "---redacted---",
          a_token: "---redacted---",
          AToken: "---redacted---",
          password: "---redacted---",
          secret: "---redacted---",
          credentials: "---redacted---",
          foo: "bar"
        }])
      end

      it 'redacts recursively' do
        data = [{
          foo: "bar",
          baz: {
            password: 'will not be dumped'
          }
        }]
        expect(redactor.redact(data)).to eql([{
          foo: "bar",
          baz: {
            password: '---redacted---'
          }
        }])
      end

      it 'uses the stop words provided at construction' do
        r = Redactor.new(blacklist: "hello and     world")
        data = {
          Hello: "bar",
          World: "foo",
          foo: "bar"
        }
        expect(r.redact(data)).to eql({
          Hello: "---redacted---",
          World: "---redacted---",
          foo: "bar"
        })
      end

      it 'redacts urls as expected' do
        r = Redactor.new
        expect(r.redact('hello')).to eql('hello')
        expect(r.redact('http://google.com')).to eql('http://google.com')
        expect(r.redact('http://google.com/a/path')).to eql('http://google.com/a/path')
        expect(r.redact('http://user@google.com')).to eql('http://--redacted--@google.com')
        expect(r.redact('http://user@google.com/a/path')).to eql('http://--redacted--@google.com/a/path')
        expect(r.redact('http://user:password@google.com')).to eql('http://--redacted--@google.com')
        expect(r.redact('http://user:password@google.com/a/path')).to eql('http://--redacted--@google.com/a/path')
      end

    end # class Redactor
  end # module Support
end # module Startback
