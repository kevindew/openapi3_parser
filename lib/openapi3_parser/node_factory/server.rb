# frozen_string_literal: true

require "openapi3_parser/node_factory/object"

module Openapi3Parser
  module NodeFactory
    class Server < NodeFactory::Object
      allow_extensions
      field "url", input_type: String, required: true
      field "description", input_type: String
      field "variables", factory: :variables_factory

      private

      def build_object(data, context)
        Node::Server.new(data, context)
      end

      def variables_factory(context)
        NodeFactory::Map.new(
          context,
          value_factory: NodeFactory::ServerVariable
        )
      end
    end
  end
end
