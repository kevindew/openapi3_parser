# frozen_string_literal: true

module Openapi3Parser
  module NodeFactory
    module Schema
      def self.factory(_context)
        NodeFactory::OptionalReference.new(V3_0)
      end
    end
  end
end
