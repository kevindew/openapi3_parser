# frozen_string_literal: true

RSpec.describe Openapi3Parser::Validators::RequiredFields do
  describe ".call" do
    it "doesn't raise an error for valid input" do
      validatable = create_validatable({})
      expect { described_class.call(validatable, required_fields: []) }
        .not_to raise_error
    end

    describe "required_fields option" do
      it "doesn't raise an error when a required field is present" do
        validatable = create_validatable({ "fieldA" => "value" })
        expect { described_class.call(validatable, required_fields: ["fieldA"]) }
          .not_to raise_error
      end

      it "raises an error when a required field is missing" do
        validatable = create_validatable({})
        expect { described_class.call(validatable, required_fields: ["fieldA"]) }
          .to raise_error(
            Openapi3Parser::Error::MissingFields,
            "Missing required fields for #/: fieldA"
          )
      end
    end

    describe "raise_on_invalid option" do
      let(:validatable) do
        create_validatable({ "fieldA" => "My field" })
      end

      it "sets errors on the validatable when invalid and raise_on_invalid is false" do
        described_class.call(validatable,
                             required_fields: ["fieldC"],
                             raise_on_invalid: false)

        expect(validatable.errors.length).to eq 1
        expect(validatable.errors.first.message).to eq "Missing required fields: fieldC"
      end

      it "doesn't set errors on the validatable when valid" do
        described_class.call(validatable,
                             required_fields: ["fieldA"],
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
