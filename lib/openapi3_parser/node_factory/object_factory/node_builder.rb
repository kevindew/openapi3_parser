# frozen_string_literal: true

module Openapi3Parser
  module NodeFactory
    module ObjectFactory
      class NodeBuilder
        def self.errors(factory)
          new(factory).errors
        end

        def self.node_data(factory, node_context)
          new(factory).node_data(node_context)
        end

        def initialize(factory)
          @factory = factory
          @validatable = Validation::Validatable.new(factory)
        end

        def errors
          return validatable.collection if empty_and_allowed_to_be?

          TypeChecker.validate_type(validatable, type: ::Hash)

          validatable.add_errors(validate(raise_on_invalid: false)) if validatable.errors.empty?

          validatable.collection
        end

        def node_data(node_context)
          return build_node_data(node_context) if empty_and_allowed_to_be?

          TypeChecker.raise_on_invalid_type(factory.context, type: ::Hash)
          validate(raise_on_invalid: true)
          build_node_data(node_context)
        end

        private_class_method :new

        private

        attr_reader :factory, :validatable

        def empty_and_allowed_to_be?
          factory.nil_input? && factory.can_use_default?
        end

        def validate(raise_on_invalid:)
          Validator.call(factory, raise_on_invalid: raise_on_invalid)
        end

        def build_node_data(node_context)
          return if factory.nil_input? && factory.data.nil?

          factory.data.each_with_object({}) do |(key, value), memo|
            memo[key] = resolve_value(key, value, node_context)
          end
        end

        def resolve_value(key, value, node_context)
          resolved = determine_value_or_default(key, value)

          if resolved.respond_to?(:node)
            Node::Placeholder.new(value, key, node_context)
          else
            resolved
          end
        end

        def determine_value_or_default(key, value)
          config = factory.field_configs[key]

          # let a field config default take precedence if value is a nil_input?
          if (value.respond_to?(:nil_input?) && value.nil_input?) || value.nil?
            default = config&.default(factory)
            default.nil? ? value : default
          else
            value
          end
        end
      end
    end
  end
end
