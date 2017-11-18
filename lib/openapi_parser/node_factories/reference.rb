# frozen_string_literal: true

require "openapi_parser/node_factory/object"

module OpenapiParser
  module NodeFactories
    class Reference
      include NodeFactory::Object

      field "$ref", input_type: String, required: true

      attr_reader :factory

      def initialize(context, factory)
        super(context)
        @factory = factory
      end

      private

      def build_object(_, context)
        context.resolve_reference do |ref_context|
          resolve_factory(ref_context).node
        end
      end

      def resolve_factory(ref_context)
        return factory.new(ref_context) if factory.is_a?(Class)
        factory.call(ref_context)
      end
    end
  end
end
