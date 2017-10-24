# frozen_string_literal: true

module OpenapiParser
  class Node
    class Components < Node
      allow_extensions

      attribute :schemas,
                object: true,
                build: :build_schemas_map

      private

      def build_schemas_map(input, document, namespace)
        Fields::ReferenceableMap.call(
          input,
          document,
          namespace
        ) do |new_input, new_document, new_namespace|
          Schema.new(new_input, new_document, new_namespace)
        end
      end
    end
  end
end
