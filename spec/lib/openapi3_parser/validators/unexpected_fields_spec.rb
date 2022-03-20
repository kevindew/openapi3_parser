# frozen_string_literal: true

RSpec.describe Openapi3Parser::Validators::UnexpectedFields do
  describe ".call" do
    it "doesn't raise an error for valid input" do
      validatable = create_validatable({})
      expect { described_class.call(validatable, allowed_fields: []) }
        .not_to raise_error
    end

    describe "allowed_fields option" do
      let(:validatable) do
        create_validatable({ "fieldA" => "My field" })
      end

      it "doesn't raise an error for an allowed field" do
        expect { described_class.call(validatable, allowed_fields: ["fieldA"]) }
          .not_to raise_error
      end

      it "raises an error when a field isn't allowed" do
        expect { described_class.call(validatable, allowed_fields: ["fieldC"]) }
          .to raise_error(
            Openapi3Parser::Error::UnexpectedFields,
            "Unexpected fields for #/: fieldA"
          )
      end
    end

    describe "extension_regex option" do
      let(:validatable) do
        create_validatable({ "x-extension" => "my extension",
                             "x-extension-2" => "my other extension" })
      end

      it "defaults to disallowing extensions" do
        validatable = create_validatable({ "extension" => "my extension" })
        expect { described_class.call(validatable, allowed_fields: []) }
          .to raise_error(Openapi3Parser::Error::UnexpectedFields, "Unexpected fields for #/: extension")
      end

      it "accepts a regex of the pattern of extension that will be accepted" do
        validatable = create_validatable({ "x-extension" => "my extension" })
        expect { described_class.call(validatable, allowed_fields: [], extension_regex: /^x-.*/) }
          .not_to raise_error
      end
    end

    describe "raise_on_invalid option" do
      let(:validatable) do
        create_validatable({ "fieldA" => "My field" })
      end

      it "sets errors on the validatable when invalid and raise_on_invalid is false" do
        described_class.call(validatable,
                             allowed_fields: ["fieldC"],
                             raise_on_invalid: false)

        expect(validatable.errors.length).to eq 1
        expect(validatable.errors.first.message).to eq "Unexpected fields: fieldA"
      end

      it "doesn't set errors on the validatable when valid" do
        described_class.call(validatable,
                             allowed_fields: ["fieldA"],
                             raise_on_invalid: false)

        expect(validatable.errors).to be_empty
      end
    end
  end

  def create_validatable(input)
    node_factory_context = create_node_factory_context(input)
    Openapi3Parser::Validation::Validatable.new(
      Openapi3Parser::NodeFactory::Map.new(node_factory_context)
    )
  end
end
