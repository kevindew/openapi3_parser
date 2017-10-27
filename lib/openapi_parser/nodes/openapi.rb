# frozen_string_literal: true

require "openapi_parser/node"
require "openapi_parser/nodes/components"

module OpenapiParser
  module Nodes
    class Openapi
      include Node

      allow_extensions

      field "openapi",
            required: true,
            input_type: String

      field "components",
            input_type: Hash,
            build: ->(input, context) { Components.new(input, context) }

      def openapi
        fields["openapi"]
      end

      # def info
      #   fields["info"]
      # end
      #
      # def servers
      #   attributes["servers"]
      # end
      #
      # def paths
      #   attributes["paths"]
      # end

      def components
        fields["components"]
      end

      # def security
      #   attributes["security"]
      # end
      #
      # def tags
      #   attributes["tags"]
      # end
      #
      # def external_docs
      #   attributes["externalDocs"]
      # end
    end
  end
end
