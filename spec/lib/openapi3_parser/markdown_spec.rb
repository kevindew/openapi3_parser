# frozen_string_literal: true

RSpec.describe Openapi3Parser::Markdown do
  describe ".to_html" do
    it "converts markdown to HTML" do
      expect(described_class.to_html("Text")).to eq("<p>Text</p>\n")
    end
  end
end
