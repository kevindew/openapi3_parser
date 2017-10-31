# frozen_string_literal: true

require "openapi_parser/error"

RSpec.shared_examples "node field" do |field, options|
  options = {
    required: nil,
    valid_input: nil,
    invalid_input: nil,
    default: nil,
    let_name: "#{field}_input".to_sym
  }.merge(options)

  unless options[:required].nil?
    context "when #{field} input is nil" do
      let(options[:let_name]) { nil }

      if options[:required]

        it "is expected to raise an error" do
          expect do
            described_class.new(input, context)
          end.to raise_error(OpenapiParser::Error)
        end

      else

        it "is expected to not raise an error" do
          expect do
            described_class.new(input, context)
          end.not_to raise_error
        end

        unless options[:default].nil?
          it "is set to a value of #{options[:default]}" do
            expect(
              described_class.new(input, context)[field]
            ).to eq options[:default]
          end
        end
      end
    end
  end

  unless options[:valid_input].nil?
    context "when #{field} input is valid" do
      let(options[:let_name]) { options[:valid_input] }

      it "is expected not to raise an error" do
        expect do
          described_class.new(input, context)
        end.not_to raise_error
      end
    end
  end

  unless options[:invalid_input].nil?
    context "when #{field} input is invalid" do
      let(options[:let_name]) { options[:invalid_input] }

      it "is expected to raise an error" do
        expect do
          described_class.new(input, context)
        end.to raise_error(OpenapiParser::Error)
      end
    end
  end

  unless options[:default].nil?
    context "when #{field} input is i" do
      let(options[:let_name]) { options[:invalid_input] }

      it "is expected to raise an error" do
        expect do
          described_class.new(input, context)
        end.to raise_error(OpenapiParser::Error)
      end
    end
  end
end
