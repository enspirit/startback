require 'spec_helper'

module Startback
  describe Context, "world" do

    let(:context) do
      SubContext.new
    end

    it 'works as expected' do
      got = context.world.partner
      expect(got).not_to be_nil
      expect(context.world.partner).to be(got)
    end

  end
end
