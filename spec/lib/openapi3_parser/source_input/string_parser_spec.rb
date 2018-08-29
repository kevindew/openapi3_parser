# frozen_string_literal: true

RSpec.describe Openapi3Parser::SourceInput::StringParser do
  describe "#call" do
    subject { described_class.call(input, filename) }
    let(:filename) { nil }

    context "when passed a valid YAML string" do
      let(:input) { "key: value\n" }
      it { is_expected.to match("key" => "value") }
    end

    context "when passed an invalid YAML string" do
      let(:input) { "*test: test\n" }
      it "raises a Psych error" do
        expect { subject }.to raise_error(Psych::Exception)
      end
    end

    context "when passed a valid JSON string" do
      let(:input) { %({ "key": "value" }) }
      it { is_expected.to match("key" => "value") }
    end

    context "when passed an invalid JSON string" do
      let(:input) { %({ "key" "value" }) }
      it "raises a JSON error" do
        expect { subject }.to raise_error(JSON::JSONError)
      end
    end

    context "when passed a YAML string with a JSON filename" do
      let(:input) { "key: value\n" }
      let(:filename) { "test.json" }
      it "raises a JSON error" do
        expect { subject }.to raise_error(JSON::JSONError)
      end
    end

    context "when passed a JSON string with a YAML filename" do
      let(:input) { %({ "key" "value" }) }
      let(:filename) { "test.yaml" }
      it "raises a Psych error" do
        expect { subject }.to raise_error(Psych::Exception)
      end
    end
  end
end
