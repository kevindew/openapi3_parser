# frozen_string_literal: true

module Openapi3Parser
  module NodeFactory
    module ObjectFactory
      class ResolvedInputBuilder
        def self.call(*args)
          new(*args).call
        end

        def initialize(initial_factory)
          @initial_factory = initial_factory
        end

        def call
          return if initial_factory.nil_input?
          # can't have resolved input if the factory doesn't resolve
          return if initial_factory.respond_to?(:resolves?) && !initial_factory.resolves?

          merge_factory_input([initial_factory] + referenced_factories)
        end

        private

        attr_reader :initial_factory

        def referenced_factories
          @referenced_factories ||= if initial_factory.respond_to?(:resolved_referenced_factories)
                                      initial_factory.resolved_referenced_factories
                                    else
                                      []
                                    end
        end

        def merge_factory_input(factories)
          input = factories.reverse.inject({}) do |memo, factory|
            next memo unless factory.data.respond_to?(:[])

            remove_reference = factory.data["$ref"]&.is_a?(NodeFactory::Fields::Reference)

            fields = factory.context.input.keys - (remove_reference ? ["$ref"] : [])

            sliced_data = factory.data.slice(*fields)
            memo.merge!(resolve_values(sliced_data))
          end

          input.compact
        end

        def resolve_values(data)
          data.transform_values do |value|
            if value.respond_to?(:in_recursive_loop?) && value.in_recursive_loop?
              RecursiveResolvedInput.new(value)
            elsif value.respond_to?(:resolved_input)
              value.resolved_input
            else
              value
            end
          end
        end
      end
    end
  end
end
