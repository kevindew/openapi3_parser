# frozen_string_literal: true

require "openapi_parser/node/object"

module OpenapiParser
  module Nodes
    class Xml
      include Node::Object

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
