# frozen_string_literal: true

module OpenapiParser
  class Node
    class Components < Node
      def schemas
        attributes["schemas"]
      end

      private

      def build_schemas_node(input, namespace)
        return nil if input.nil?
        raise_unless_hash_like(input, namespace)
      end
    end
  end
end
