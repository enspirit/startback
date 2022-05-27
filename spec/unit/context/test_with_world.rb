require 'spec_helper'

module Startback
  describe Context, "with_world" do

    let(:who) do
      Object.new
    end

    let(:context) do
      SubContext.new.with_world(hello: who)
    end

    it 'works as expected' do
      got = context.world.hello
      expect(got).to be(who)
    end

  end
end
