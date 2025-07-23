# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Structs::Model, :db do
  subject(:model) { Factory[:model] }

  describe "#dimensions" do
    it "answers dimensions" do
      expect(model.dimensions).to eq("800x480")
    end
  end
end
