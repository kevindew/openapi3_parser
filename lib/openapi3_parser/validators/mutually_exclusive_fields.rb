# frozen_string_literal: true

require "openapi3_parser/array_sentence"

module Openapi3Parser
  module Validators
    class MutuallyExclusiveFields
      using ArraySentence
      private_class_method :new

      def self.call(*args, **kwargs)
        new.call(*args, **kwargs)
      end

      def call(validatable,
               mutually_exclusive_fields:,
               raise_on_invalid: true)
        mutually_exclusive = MutuallyExclusiveFieldErrors.new(
          mutually_exclusive_fields, validatable.input
        )

        handle_required_errors(validatable,
                               mutually_exclusive.required_errors,
                               raise_on_invalid)
        handle_exclusive_errors(validatable,
                                mutually_exclusive.exclusive_errors,
                                raise_on_invalid)
      end

      private

      def handle_required_errors(validatable,
                                 required_errors,
                                 raise_on_invalid)
        return unless required_errors.any?

        if raise_on_invalid
          location_summary = validatable.context.location_summary
          raise Error::MissingFields,
                "Mutually exclusive fields for "\
                "#{location_summary}: #{required_errors.first}"
        else
          validatable.add_errors(required_errors)
        end
      end

      def handle_exclusive_errors(validatable,
                                  exclusive_errors,
                                  raise_on_invalid)
        return unless exclusive_errors.any?

        if raise_on_invalid
          location_summary = validatable.context.location_summary
          raise Error::UnexpectedFields,
                "Mutually exclusive fields for "\
                "#{location_summary}: "\
                "#{exclusive_errors.first}"
        else
          validatable.add_errors(exclusive_errors)
        end
      end

      class MutuallyExclusiveFieldErrors
        using ArraySentence

        def initialize(mutually_exclusive_fields, input)
          @mutually_exclusive_fields = mutually_exclusive_fields
          @input = input
        end

        def required_errors
          errors[:required]
        end

        def exclusive_errors
          errors[:exclusive]
        end

        def errors
          @errors ||= begin
            default = { required: [], exclusive: [] }
            mutually_exclusive_fields
              .each_with_object(default) do |exclusive, errors|
                add_error(errors, exclusive)
              end
          end
        end

        private

        attr_reader :mutually_exclusive_fields, :input

        def add_error(errors, mutually_exclusive)
          fields = mutually_exclusive.fields
          number_non_nil = count_non_nil_fields(fields)
          if number_non_nil.zero? && mutually_exclusive.required
            errors[:required] << required_error(fields)
          elsif number_non_nil > 1
            errors[:exclusive] << exclusive_error(fields)
          end
        end

        def count_non_nil_fields(fields)
          fields.count do |field|
            data = input[field]
            data.respond_to?(:nil_input?) ? !data.nil_input? : !data.nil?
          end
        end

        def required_error(fields)
          "One of #{fields.sentence_join} is required"
        end

        def exclusive_error(fields)
          "#{fields.sentence_join} are mutually exclusive fields"
        end
      end
    end
  end
end
