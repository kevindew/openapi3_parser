# frozen_string_literal: true

module Openapi3Parser
  module NodeFactory
    module Schema
      def self.factory(context)
        if context.openapi_version >= "3.1"
          OasDialect3_1
        else
          NodeFactory::OptionalReference.new(V3_0)
        end
      end

      def self.build_factory(context)
        fetched_factory = factory(context)

        if fetched_factory.is_a?(Class)
          fetched_factory.new(context)
        else
          fetched_factory.call(context)
        end
      end
    end
  end
end
