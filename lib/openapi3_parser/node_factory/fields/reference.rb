# frozen_string_literal: true

require "openapi3_parser/node_factory"
require "openapi3_parser/validators/reference"

module Openapi3Parser
  module NodeFactory
    module Fields
      class Reference
        include NodeFactory
        input_type ::String

        def initialize(context, factory)
          super(context)
          @factory = factory
          @given_reference = context.input
          @reference_resolver = create_reference_resolver
        end

        def data
          reference_resolver&.data
        end

        private

        attr_reader :given_reference, :factory, :reference_resolver

        def validate(_, _)
          return reference_validator.errors unless reference_validator.valid?
          reference_resolver&.errors
        end

        def build_node(_)
          reference_resolver&.node
        end

        def reference_validator
          @reference_validator ||= Validators::Reference.new(given_reference)
        end

        def create_reference_resolver
          return unless given_reference
          context.register_reference(given_reference, factory)
        end
      end
    end
  end
end
