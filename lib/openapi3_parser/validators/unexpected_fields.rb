# frozen_string_literal: true

require "openapi3_parser/array_sentence"

module Openapi3Parser
  module Validators
    class UnexpectedFields
      using ArraySentence
      private_class_method :new

      def self.call(*args, **kwargs)
        new.call(*args, **kwargs)
      end

      def call(validatable,
               allowed_fields:,
               extension_regex: nil,
               raise_on_invalid: true)
        fields = unexpected_fields(validatable.input,
                                   allowed_fields,
                                   extension_regex)
        return if fields.empty?

        if raise_on_invalid
          location_summary = validatable.context.location_summary
          raise Openapi3Parser::Error::UnexpectedFields,
                "Unexpected fields for #{location_summary}: " \
                "#{fields.sentence_join}"
        else
          validatable.add_error(
            "Unexpected fields: #{fields.sentence_join}"
          )
        end
      end

      private

      def unexpected_fields(input, allowed_fields, extension_regex)
        extra_keys = input.keys - allowed_fields
        return extra_keys unless extension_regex

        extra_keys.grep_v(extension_regex)
      end
    end
  end
end
