require 'spec_helper'

module Startback
  describe Support do
    include Support

    describe "deep_merge" do

      it 'works as expected' do
        h1 = {
          :foo => "bar",
          :bar => "unchanged",
          :baz => {
            "hello" => "world",
            "changed" => "yes"
          }
        }
        h2 = {
          :foo => "baz",
          :baz => {
            "eloy" => "tom",
            "changed" => "no"
          }
        }
        expected = {
          :foo => "baz",
          :bar => "unchanged",
          :baz => {
            "hello" => "world",
            "eloy" => "tom",
            "changed" => "no"
          }
        }
        expect(deep_merge(h1, h2)).to eql(expected)
      end

    end

  end
end
