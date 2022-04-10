# frozen_string_literal: true

module Openapi3Parser
  module NodeFactory
    module ObjectFactory
      class NodeBuilder
        def initialize(initial_factory, initial_node_context)
          @initial_factory = initial_factory
          @initial_node_context = initial_node_context
        end

        def node_data
          @node_data ||= build_node_data
        end

        def node_context
          @node_context ||= referenced_factories.inject(initial_node_context) do |node_context, factory|
            Node::Context.resolved_reference(node_context, factory.context)
          end
        end

        def factory_to_build
          referenced_factories.last || initial_factory
        end

        def build_node
          return unless node_data

          factory_to_build.build_node(node_data, node_context)
        end

        private

        attr_reader :initial_factory, :initial_node_context

        def referenced_factories
          @referenced_factories ||= if initial_factory.respond_to?(:resolved_referenced_factories)
                                      initial_factory.resolved_referenced_factories
                                    else
                                      []
                                    end
        end

        def build_node_data
          empty_and_allowed_to_be = initial_factory.nil_input? && initial_factory.can_use_default?
          return resolve_node_data_values(initial_factory.data) if empty_and_allowed_to_be

          validate

          data = merged_node_data

          # remove any references we have
          data.delete("$ref")

          resolve_node_data_values(data)
        end

        def merged_node_data
          factories = [initial_factory] + referenced_factories

          # Use the last factory in a reference chain as the base, then merge
          # data onto it
          base_data = factories.last.data

          factories.reverse[1..].inject(base_data) do |memo, factory|
            sliced_data = factory.data.slice(*factory.context.input.keys)
            memo.merge(sliced_data)
          end
        end

        def validate
          TypeChecker.raise_on_invalid_type(initial_factory.context, type: ::Hash)
          Validator.call(initial_factory, raise_on_invalid: true)

          # most fields are validated during building, however we delete $ref
          # fields so need to validate them separately
          ([initial_factory] + referenced_factories).each do |factory|
            next unless factory.data.respond_to?(:[])
            next unless factory.data["$ref"].is_a?(NodeFactory::Fields::Reference)

            NodeFactory::Field::Validator.call(factory.data["$ref"], raise_on_invalid: true)
          end
        end

        def resolve_node_data_values(factory_data)
          return if factory_data.nil?

          factory_data.each_with_object({}) do |(key, value), memo|
            resolved = determine_value_or_default(key, value)

            memo[key] = if resolved.respond_to?(:node)
                          Node::Placeholder.new(value, key, node_context)
                        else
                          resolved
                        end
          end
        end

        def determine_value_or_default(key, value)
          factory_to_build = referenced_factories.any? ? referenced_factories.last : initial_factory
          config = factory_to_build.field_configs[key]

          # let a field config default take precedence if value is a nil_input?
          if (value.respond_to?(:nil_input?) && value.nil_input?) || value.nil?
            default = config&.default(factory_to_build)
            default.nil? ? value : default
          else
            value
          end
        end
      end
    end
  end
end
