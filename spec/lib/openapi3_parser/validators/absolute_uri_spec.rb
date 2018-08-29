# frozen_string_literal: true

RSpec.describe Openapi3Parser::Validators::AbsoluteUri do
  describe ".call" do
    subject { described_class.call(uri) }

    context "when input is an invalid URI" do
      let(:uri) { "not a uri" }
      it { is_expected.to eq %("#{uri}" is not a valid URI) }
    end

    context "when input is an FTP URI" do
      let(:uri) { "ftp://ftp.example.com/ruby/src" }
      it { is_expected.to be_nil }
    end

    context "when input is a relative URI" do
      let(:uri) { "test?query=blah#anchor" }
      it { is_expected.to eq %("#{uri}" is not a absolute URI) }
    end

    context "when input is a valid HTTP URI" do
      let(:uri) { "http://example.com/test?query=blah#anchor" }
      it { is_expected.to be_nil }
    end
  end
end
