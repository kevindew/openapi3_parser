# frozen_string_literal: true

require "openapi3_parser/context"
require "openapi3_parser/node_factory"
require "openapi3_parser/validation/error"

module Openapi3Parser
  module NodeFactory
    module Object
      class Validator
        def self.missing_required_fields(input, factory)
          configs = factory.field_configs
          configs.each_with_object([]) do |(name, field_config), memo|
            f = input[name]
            is_nil = f.respond_to?(:nil_input?) ? f.nil_input? : f.nil?
            memo << name if field_config.required?(factory) && is_nil
          end
        end

        def self.unexpected_fields(input, factory)
          unexpected_keys = input.keys - factory.field_configs.keys
          if factory.allowed_extensions?
            unexpected_keys.reject { |k| k =~ NodeFactory::EXTENSION_REGEX }
          else
            unexpected_keys
          end
        end

        def initialize(input, factory)
          @input = input
          @factory = factory
        end

        def errors
          [
            missing_required_fields_error,
            unexpected_fields_error,
            mututally_exclusive_fields_errors,
            invalid_field_errors
          ].flatten.compact
        end

        private

        attr_reader :input, :factory

        def context
          factory.context
        end

        def raw_input
          context.input
        end

        def missing_required_fields_error
          fields = self.class.missing_required_fields(input, factory)
          return unless fields.any?
          Validation::Error.new(
            "Missing required fields: #{fields.join(', ')}",
            context,
            factory.class
          )
        end

        def unexpected_fields_error
          fields = self.class.unexpected_fields(input, factory)
          return unless fields.any?
          Validation::Error.new(
            "Unexpected fields: #{fields.join(', ')}",
            context,
            factory.class
          )
        end

        def invalid_field_errors
          factory.field_configs.inject([]) do |memo, (name, field_config)|
            memo + Array(field_errors(name, field_config))
          end
        end

        def mututally_exclusive_fields_errors
          MututallyExclusiveFieldErrors.call(factory, input)
        end

        def field_errors(name, field_config)
          return if input[name].nil?
          field = input[name]

          if field.respond_to?(:errors) && !field.errors.empty?
            field.errors.to_a
          else
            build_type_error(name, field_config) ||
              build_validation_errors(name, field_config)
          end
        end

        def build_type_error(name, field_config)
          type_error = field_config.input_type_error(raw_input[name], factory)
          return unless type_error
          Validation::Error.new(
            "Invalid type: #{type_error}",
            Context.next_field(context, name),
            factory.class
          )
        end

        def build_validation_errors(name, field_config)
          field_config.validation_errors(
            raw_input[name], factory
          ).map do |error|
            Validation::Error.new(
              error,
              Context.next_field(context, name),
              factory.class
            )
          end
        end

        class MututallyExclusiveFieldErrors
          def self.call(*args)
            new.call(*args)
          end

          def call(factory, input)
            factory
              .mutually_exclusive_fields
              .each_with_object([]) do |mutually_exclusive, memo|
                error = determine_error(mutually_exclusive, input, factory)
                memo << error if error
              end
          end

          private

          def determine_error(mutually_exclusive, input, factory)
            fields = mutually_exclusive.fields
            number_non_nil = count_non_nil_fields(fields, input)

            if number_non_nil.zero? && mutually_exclusive.required
              required_error(fields, factory)
            elsif number_non_nil > 1
              exclusive_error(fields, factory)
            end
          end

          def count_non_nil_fields(fields, input)
            fields.count do |field|
              data = input[field]
              data.respond_to?(:nil_input?) ? !data.nil_input? : !data.nil?
            end
          end

          def required_error(fields, factory)
            Validation::Error.new(
              "one of #{sentence_fields(fields)} is required",
              factory.context,
              factory.class
            )
          end

          def exclusive_error(fields, factory)
            Validation::Error.new(
              "#{sentence_fields(fields)} are mutually exclusive fields",
              factory.context,
              factory.class
            )
          end

          def sentence_fields(fields)
            fields[0..-2].join(", ") + " and " + fields[-1]
          end
        end
      end
    end
  end
end
