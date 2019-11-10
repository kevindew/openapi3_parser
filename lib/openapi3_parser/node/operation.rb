# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#operationObject
    class Operation < Node::Object
      # @return [Node::Array<String>]
      def tags
        self["tags"]
      end

      # @return [String, nil]
      def summary
        self["summary"]
      end

      # @return [String, nil]
      def description
        self["description"]
      end

      # @return [String, nil]
      def description_html
        render_markdown(description)
      end

      # @return [ExternalDocumentation, nil]
      def external_docs
        self["externalDocs"]
      end

      # @return [String, nil]
      def operation_id
        self["operationId"]
      end

      # @return [Node::Array<Parameter>]
      def parameters
        self["parameters"]
      end

      # @return [RequestBody, nil]
      def request_body
        self["requestBody"]
      end

      # @return [Responses]
      def responses
        self["responses"]
      end

      # @return [Map<String, Callback>]
      def callbacks
        self["callbacks"]
      end

      # @return [Boolean]
      def deprecated?
        self["deprecated"]
      end

      # @return [Node::Array<SecurityRequirement>]
      def security
        self["security"]
      end

      # @return [Node::Array<Server>]
      def servers
        self["servers"]
      end

      # Whether this object uses it's own defined servers instead of falling
      # back to the path items' ones.
      #
      # @return [Boolean]
      def alternative_servers?
        servers != node_context.parent_node.servers
      end
    end
  end
end
