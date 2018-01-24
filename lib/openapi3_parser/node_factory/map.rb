# frozen_string_literal: true

require "openapi3_parser/node_factory"
require "openapi3_parser/validation/error_collection"

module Openapi3Parser
  module NodeFactory
    module Map
      include NodeFactory

      def self.included(base)
        base.extend(NodeFactory::ClassMethods)
        base.class_eval do
          input_type Hash
        end
      end

      private

      def build_node(input)
        data = input.each_with_object({}) do |(key, value), memo|
          memo[key] = value.respond_to?(:node) ? value.node : value
        end
        build_map(data, context)
      end

      def validate_input
        processed_input.each_value.inject(super) do |memo, value|
          errors = value.respond_to?(:errors) ? value.errors : []
          Validation::ErrorCollection.combine(memo, errors)
        end
      end

      def build_map(data, _)
        data
      end

      def default
        {}
      end
    end
  end
end
