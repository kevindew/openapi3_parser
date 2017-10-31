# frozen_string_literal: true

require "openapi_parser/node"

module OpenapiParser
  module Nodes
    class Xml
      include Node

      allow_extensions

      field "name", input_type: String
      field "namespace", input_type: String
      field "prefix", input_type: String
      field "attribute", input_type: :boolean, default: false
      field "wrapped", input_type: :boolean, default: false

      def name
        fields["name"]
      end

      def namespace
        fields["namespace"]
      end

      def prefix
        fields["prefix"]
      end

      def attribute
        fields["attribute"]
      end

      def wrapped
        fields["wrapped"]
      end
    end
  end
end
