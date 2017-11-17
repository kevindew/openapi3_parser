# frozen_string_literal: true

require "openapi_parser/node/object"

module OpenapiParser
  module Nodes
    class Discriminator
      include Node::Object

      def property_name
        fields["propertyName"]
      end

      def mapping
        fields["mapping"]
      end
    end
  end
end
