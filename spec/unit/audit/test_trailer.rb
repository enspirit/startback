require 'spec_helper'
require 'startback/audit'
module Startback
  module Audit
    describe Trailer do

      let(:trailer) {
        Trailer.new("/tmp/trail.log")
      }

      describe "op_name" do

        def op_name(op, trailer = self.trailer)
          trailer.send(:op_name, op)
        end

        it 'uses op_name in priority if provided' do
          op = OpenStruct.new(op_name: "foo")
          expect(op_name(op)).to eql("foo")
        end
      end

      describe "op_data" do

        def op_data(op, trailer = self.trailer)
          trailer.send(:op_data, op)
        end

        it 'uses op_data in priority if provided' do
          op = OpenStruct.new(op_data: { foo: "bar" }, input: 12, request: 13)
          expect(op_data(op)).to eql({ foo: "bar" })
        end

        it 'uses to_trail then' do
          op = OpenStruct.new(to_trail: { foo: "bar" }, input: 12, request: 13)
          expect(op_data(op)).to eql({ foo: "bar" })
        end

        it 'uses input then' do
          op = OpenStruct.new(input: { foo: "bar" }, request: 13)
          expect(op_data(op)).to eql({ foo: "bar" })
        end

        it 'uses request then' do
          op = OpenStruct.new(request: { foo: "bar" })
          expect(op_data(op)).to eql({ foo: "bar" })
        end

        it 'applies default blacklists for security reasons' do
          op = OpenStruct.new(input: {
            token: "will not be dumped",
            a_token: "will not be dumped",
            AToken: "will not be dumped",
            password: "will not be dumped",
            secret: "will not be dumped",
            credentials: "will not be dumped",
            foo: "bar"
          })
          expect(op_data(op)).to eql({
            foo: "bar"
          })
        end

        it 'applies default blacklists to data arrays too' do
          op = OpenStruct.new(input: [{
            token: "will not be dumped",
            a_token: "will not be dumped",
            AToken: "will not be dumped",
            password: "will not be dumped",
            secret: "will not be dumped",
            credentials: "will not be dumped",
            foo: "bar"
          }])
          expect(op_data(op)).to eql([{
            foo: "bar"
          }])
        end

        it 'uses the stop words provided at construction' do
          t = Trailer.new("/tmp/trail.log", blacklist: "hello and     world")
          op = OpenStruct.new(request: { Hello: "bar", World: "foo", foo: "bar" })
          expect(op_data(op, t)).to eql({ foo: "bar" })
        end

      end

      describe "op_context" do

        def op_context(op, trailer = self.trailer)
          trailer.send(:op_context, op)
        end

        it 'applies default blacklists for security reasons' do
          op = OpenStruct.new(context: {
            token: "will not be dumped",
            foo: "bar"
          })
          expect(op_context(op)).to eql({ foo: "bar" })
        end

      end

    end
  end
end
