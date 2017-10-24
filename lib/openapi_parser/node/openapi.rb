# frozen_string_literal: true

module OpenapiParser
  class Node
    class Openapi < Node
      allow_extensions

      attribute :openapi,
                required: true,
                string: true

      attribute :components,
                required: true,
                object: true,
                build: ->(input, document, namespace) do
                  Components.new(input, document, namespace)
                end

      # def openapi
      #   attributes["openapi"]
      # end

      def info
        attributes["info"]
      end

      def servers
        attributes["servers"]
      end

      def paths
        attributes["paths"]
      end

      def components
        attributes["components"]
      end

      def security
        attributes["security"]
      end

      def tags
        attributes["tags"]
      end

      def external_docs
        attributes["externalDocs"]
      end

      private

      def build_info_node(input, namespace)
        return nil if input.nil?
        raise_unless_hash_like(input, namespace)
        Info.new(input, document, namespace)
      end

      def build_components_node(input, document, namespace)
        Components.new(input, document, namespace)
      end
    end
  end
end
