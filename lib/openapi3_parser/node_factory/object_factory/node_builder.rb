# frozen_string_literal: true

module Openapi3Parser
  module NodeFactory
    module ObjectFactory
      class NodeBuilder
        def self.errors(factory)
          new(factory).errors
        end

        def self.node_data(factory)
          new(factory).node_data
        end

        def initialize(factory)
          @factory = factory
          @validatable = Validation::Validatable.new(factory)
        end

        def errors
          return validatable.collection if empty_and_allowed_to_be?

          TypeChecker.validate_type(validatable, type: ::Hash)

          if validatable.errors.empty?
            validatable.add_errors(validate(raise_on_invalid: false))
          end

          validatable.collection
        end

        def node_data
          return build_node_data if empty_and_allowed_to_be?
          TypeChecker.raise_on_invalid_type(factory.context, type: ::Hash)
          validate(raise_on_invalid: true)
          build_node_data
        end

        private_class_method :new

        private

        attr_reader :factory, :validatable

        def empty_and_allowed_to_be?
          factory.nil_input? && factory.can_use_default?
        end

        def validate(raise_on_invalid:)
          Validator.call(factory, raise_on_invalid)
        end

        def build_node_data
          return if factory.nil_input? && factory.data.nil?

          factory.data.each_with_object(NodeData.new) do |(key, value), memo|
            memo[key] = if node_is_recursive_pointer?(value)
                          value.recursive_pointer
                        else
                          resolve_value(key, value)
                        end
          end
        end

        def resolve_value(key, value)
          config = factory.field_configs[key]
          resolved_value = value.respond_to?(:node) ? value.node : value

          # let a field config default take precedence if value is a nil_input?
          if (value.respond_to?(:nil_input?) && value.nil_input?) || value.nil?
            default = config&.default(factory)
            default.nil? ? resolved_value : default
          else
            resolved_value
          end
        end

        def node_is_recursive_pointer?(value_factory)
          return false unless value_factory.respond_to?(:in_recursive_loop?)
          value_factory.in_recursive_loop?
        end

        class NodeData < ::Hash
          def [](key)
            item = super(key)
            item.is_a?(NodeFactory::RecursivePointer) ? item.node : item
          end
        end
      end
    end
  end
end
