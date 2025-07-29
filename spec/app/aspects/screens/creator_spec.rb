# frozen_string_literal: true

require "hanami_helper"
require "mini_magick"

RSpec.describe Terminus::Aspects::Screens::Creator, :db do
  subject(:creator) { described_class.new }

  include_context "with temporary directory"

  describe "#call" do
    let(:model) { Factory[:model] }
    let(:content) { Base64.strict_encode64 SPEC_ROOT.join("support/fixtures/test.png").read }
    let(:output_path) { temp_dir.join "test.png" }

    it "saves HTML as screen" do
      result = creator.call model_id: model.id,
                            label: "Test",
                            name: "test",
                            content: "<h1>Test</h1>"

      expect(result.success).to have_attributes(
        model_id: model.id,
        name: "test",
        label: "Test",
        image_attributes: hash_including(
          metadata: hash_including(
            size: kind_of(Integer),
            width: 800,
            height: 480,
            filename: "test.png",
            mime_type: "image/png"
          )
        )
      )
    end

    it "saves preprocessed URI as screen" do
      result = creator.call model_id: model.id,
                            label: "Test",
                            name: "test",
                            uri: SPEC_ROOT.join("support/fixtures/test.png"),
                            preprocessed: true

      expect(result.success).to have_attributes(
        model_id: model.id,
        name: "test",
        label: "Test",
        image_attributes: hash_including(
          metadata: hash_including(
            size: kind_of(Integer),
            width: 1,
            height: 1,
            filename: "test.png",
            mime_type: "image/png"
          )
        )
      )
    end

    it "saves unprocessed URI as screen" do
      result = creator.call model_id: model.id,
                            label: "Test",
                            name: "test",
                            uri: SPEC_ROOT.join("support/fixtures/test.png")

      expect(result.success).to have_attributes(
        model_id: model.id,
        name: "test",
        label: "Test",
        image_attributes: hash_including(
          metadata: hash_including(
            size: kind_of(Integer),
            width: 800,
            height: 480,
            filename: "test.png",
            mime_type: "image/png"
          )
        )
      )
    end

    it "saves encoded data as screen" do
      data = Base64.strict_encode64 SPEC_ROOT.join("support/fixtures/test.png").read
      result = creator.call(model_id: model.id, label: "Test", name: "test", data:)

      expect(result.success).to have_attributes(
        model_id: model.id,
        name: "test",
        label: "Test",
        image_attributes: hash_including(
          metadata: hash_including(
            size: kind_of(Integer),
            width: 800,
            height: 480,
            filename: "test.png",
            mime_type: "image/png"
          )
        )
      )
    end

    it "answers failure with nil value" do
      expect(creator.call(model_id: nil)).to be_failure("Unable to find model for ID: nil.")
    end

    it "answers failure with no parameters" do
      expect(creator.call(model_id: 666)).to be_failure("Unable to find model for ID: 666.")
    end

    it "answers failure with invalid parameters" do
      expect(creator.call(model_id: model.id, bogus: :danger)).to be_failure(
        "Invalid parameters: {bogus: :danger}."
      )
    end
  end
end
