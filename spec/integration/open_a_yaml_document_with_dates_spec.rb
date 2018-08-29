# frozen_string_literal: true

require "openapi3_parser"

# This is to test that YAML doesn't blow up when we encounter a Date or Time
# (which are valid types in YAML) - these should be avoided however as these
# are expected to be strings.
RSpec.describe "Open a YAML Document with dates" do
  before do
    stub_request(:get, "example.com/openapi.yml")
      .to_return(body: body)
  end

  let(:url) { "http://example.com/openapi.yml" }
  subject(:document) { Openapi3Parser.load_url(url) }
  let(:body) do
    <<~HEREDOC
      ---
      openapi: 3.0.1
      info:
        title: 2017-02-03T17:43:22.000Z
        other: 2017-02-03
        version: 1.0.0
      paths: {}
    HEREDOC
  end

  it { is_expected.not_to be_valid }
end
