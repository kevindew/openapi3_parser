# frozen_string_literal: true

RSpec.describe Openapi3Parser::SourceInput::StringParser do
  describe "#call" do
    it "can parse a YAML string" do
      expect(described_class.call("key: value\n"))
        .to match("key" => "value")
    end

    it "can parse a JSON string" do
      expect(described_class.call(%({ "key": "value" })))
        .to match("key" => "value")
    end

    it "raises an error when the input is invalid YAML" do
      input = "*test: test\n"
      expect { described_class.call(input) }
        .to raise_error(Psych::Exception)
    end

    it "raises an error when the input is invalid JSON" do
      input = %({ "key" "value" })
      expect { described_class.call(input) }
        .to raise_error(JSON::JSONError)
    end

    it "treats a file as YAML if the filename ends in .yaml" do
      json_input = %({ "key" "value" })
      expect { described_class.call(json_input, "file.yaml") }
        .to raise_error(Psych::Exception)
    end

    it "treats a file as JSON if the filename ends in .json" do
      yaml_input = "key: value\n"
      expect { described_class.call(yaml_input, "file.json") }
        .to raise_error(JSON::JSONError)
    end
  end
end
