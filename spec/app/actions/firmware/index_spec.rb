# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::Firmware::Index, :db do
  subject(:action) { described_class.new }

  include_context "with application dependencies"

  describe "#call" do
    let(:firmware) { Factory[:firmware, :with_attachment] }
    let(:proof) { %(<a download="test.bin" href="memory://abc123.bin">0.0.0</a>) }

    before { firmware }

    it "renders standard response with search results" do
      response = Rack::MockRequest.new(action).get "", params: {query: "0.0"}
      expect(response.body).to match(proof)
    end

    it "renders standard response with no results" do
      response = Rack::MockRequest.new(action).get "", params: {query: "bogus"}
      expect(response.body).to include("No firmware found.")
    end

    it "renders htmx response with search results" do
      response = Rack::MockRequest.new(action).get "",
                                                   "HTTP_HX_TRIGGER" => "search",
                                                   params: {query: "0.0"}

      expect(response.body).to match(proof)
    end

    it "renders htmx response with no results" do
      response = Rack::MockRequest.new(action).get "",
                                                   "HTTP_HX_TRIGGER" => "search",
                                                   params: {query: "bogus"}

      expect(response.body).to include("No firmware found.")
    end

    it "renders all devices with empty query" do
      response = Rack::MockRequest.new(action).get "", params: {query: ""}
      expect(response.body).to match(proof)
    end

    it "renders all devices with no query" do
      response = Rack::MockRequest.new(action).get ""
      expect(response.body).to match(proof)
    end
  end
end
