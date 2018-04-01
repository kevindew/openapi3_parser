# frozen_string_literal: true

require "openapi3_parser/context"
require "openapi3_parser/node_factories/response"
require "openapi3_parser/node_factory/map"
require "openapi3_parser/node_factory/optional_reference"
require "openapi3_parser/node/responses"

module Openapi3Parser
  module NodeFactories
    class Responses
      include NodeFactory::Map

      KEY_REGEX = /
        \A
        (
        default
        |
        [1-5]([0-9][0-9]|XX)
        )
        \Z
      /x

      private

      def process_input(input)
        input.each_with_object({}) do |(key, value), memo|
          memo[key] = value if extension?(key)
          next_context = Context.next_field(context, key)
          memo[key] = child_factory(next_context)
        end
      end

      def child_factory(child_context)
        NodeFactory::OptionalReference.new(NodeFactories::Response)
                                      .call(child_context)
      end

      def build_map(data, context)
        Node::Responses.new(data, context)
      end

      def validate(input, _context)
        validate_keys(input.keys)
      end

      def validate_keys(keys)
        invalid = keys.reject do |key|
          extension?(key) || KEY_REGEX.match(key)
        end

        return if invalid.empty?

        codes = invalid.map { |k| "'#{k}'" }.join(", ")
        "Invalid responses keys: #{codes} - default, status codes and status "\
        "code ranges allowed"
      end
    end
  end
end
