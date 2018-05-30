# frozen_string_literal: true

require "openapi3_parser/array_sentence"
require "openapi3_parser/error"

module Openapi3Parser
  module Validators
    class UnexpectedFields
      using ArraySentence
      private_class_method :new

      def self.call(*args)
        new.call(*args)
      end

      def call(validatable,
               allow_extensions: true,
               allowed_fields: nil,
               raise_on_invalid: true)
        fields = unexpected_fields(validatable.input,
                                   allowed_fields,
                                   allow_extensions)
        return if fields.empty?

        if raise_on_invalid
          location_summary = validatable.context.location_summary
          raise Openapi3Parser::Error::UnexpectedFields,
                "Unexpected fields for #{location_summary}: "\
                "#{fields.sentence_join}"
        else
          validatable.add_error(
            "Unexpected fields: #{fields.sentence_join}"
          )
        end
      end

      private

      def unexpected_fields(input, allowed_fields, allow_extensions)
        if allowed_fields
          extra_keys = input.keys - allowed_fields
          return extra_keys unless allow_extensions
          extra_keys.reject { |key| key =~ NodeFactory::EXTENSION_REGEX }
        elsif !allow_extensions
          input.keys.select { |key| key =~ NodeFactory::EXTENSION_REGEX }
        else
          []
        end
      end
    end
  end
end
