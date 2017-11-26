# frozen_string_literal: true

require "openapi3_parser/node_factory"

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

      def validate_input(error_collection)
        super(error_collection)
        processed_input.each_value do |value|
          next unless value.respond_to?(:errors)
          error_collection.merge(value.errors)
        end
      end

      def build_map(data, _)
        data
      end
    end
  end
end
