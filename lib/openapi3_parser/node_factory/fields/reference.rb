# frozen_string_literal: true

require "openapi3_parser/context"
require "openapi3_parser/node_factory/field"
require "openapi3_parser/validators/reference"

module Openapi3Parser
  module NodeFactory
    module Fields
      class Reference < NodeFactory::Field
        def initialize(context, factory)
          context = Context.as_reference(context)
          super(context, input_type: String, validate: :validate)
          @factory = factory
          @reference = context.input
          @reference_resolver = create_reference_resolver
        end

        def resolved_input
          reference_resolver&.resolved_input
        end

        private

        attr_reader :reference, :factory, :reference_resolver

        def build_node(_data)
          reference_resolver&.node
        end

        def validate(validatable)
          if reference_validator.valid?
            validatable.add_errors(reference_validator.errors)
          else
            validatable.add_errors(reference_resolver&.errors)
          end
        end

        def reference_validator
          @reference_validator ||= Validators::Reference.new(reference)
        end

        def create_reference_resolver
          return unless reference
          context.register_reference(reference, factory)
        end
      end
    end
  end
end
