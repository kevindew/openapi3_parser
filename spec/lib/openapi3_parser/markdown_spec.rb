# frozen_string_literal: true

RSpec.describe Openapi3Parser::Markdown do
  describe ".to_html" do
    subject { described_class.to_html(text) }
    let(:text) { "Text" }
    it { is_expected.to eq "<p>Text</p>\n" }
  end
end
