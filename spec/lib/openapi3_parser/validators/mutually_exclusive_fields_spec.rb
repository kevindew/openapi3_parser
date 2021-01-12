# frozen_string_literal: true

RSpec.describe Openapi3Parser::Validators::MutuallyExclusiveFields do
  let(:mutually_exclusive_field_klass) do
    Openapi3Parser::NodeFactory::ObjectFactory::Dsl::MutuallyExclusiveField
  end

  describe ".call" do
    it "doesn't raise an error for valid input" do
      validatable = create_validatable({})
      expect { described_class.call(validatable, mutually_exclusive_fields: []) }
        .not_to raise_error
    end

    describe "mutually_exclusive_fields option" do
      it "doesn't raise an error when one of the fields is present" do
        validatable = create_validatable({ "fieldA" => true })
        exclusive = mutually_exclusive_field_klass.new(
          fields: %w[fieldA fieldB],
          required: false
        )
        expect { described_class.call(validatable, mutually_exclusive_fields: [exclusive]) }
          .not_to raise_error
      end

      it "raises an error when multiple mutually exclusive fields are present" do
        validatable = create_validatable({ "fieldA" => true, "fieldB" => true })
        exclusive = mutually_exclusive_field_klass.new(
          fields: %w[fieldA fieldB],
          required: false
        )
        expect { described_class.call(validatable, mutually_exclusive_fields: [exclusive]) }
          .to raise_error(
            Openapi3Parser::Error::UnexpectedFields,
            "Mutually exclusive fields for #/: fieldA and fieldB are mutually exclusive fields"
          )
      end

      it "doesn't raise an error when none of the fields is provided and required is false" do
        validatable = create_validatable({})
        exclusive = mutually_exclusive_field_klass.new(
          fields: %w[fieldA fieldB],
          required: false
        )
        expect { described_class.call(validatable, mutually_exclusive_fields: [exclusive]) }
          .not_to raise_error
      end

      it "raises an error when none of the fields are provided and required is true" do
        validatable = create_validatable({})
        exclusive = mutually_exclusive_field_klass.new(
          fields: %w[fieldA fieldB],
          required: true
        )
        expect { described_class.call(validatable, mutually_exclusive_fields: [exclusive]) }
          .to raise_error(
            Openapi3Parser::Error::MissingFields,
            "Mutually exclusive fields for #/: One of fieldA and fieldB is required"
          )
      end
    end

    describe "raise_on_invalid option" do
      let(:mutually_exclusive_field) do
        mutually_exclusive_field_klass.new(
          fields: %w[fieldA fieldB],
          required: false
        )
      end

      it "sets errors on the validatable when invalid and raise_on_invalid is false" do
        validatable = create_validatable({ "fieldA" => true, "fieldB" => true })
        described_class.call(validatable,
                             mutually_exclusive_fields: [mutually_exclusive_field],
                             raise_on_invalid: false)

        expect(validatable.errors.length).to eq 1
        expect(validatable.errors.first.message)
          .to eq "fieldA and fieldB are mutually exclusive fields"
      end

      it "doesn't set errors on the validatable when valid" do
        validatable = create_validatable({ "fieldA" => true })
        described_class.call(validatable,
                             mutually_exclusive_fields: [mutually_exclusive_field],
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
