# frozen_string_literal: true

require "forwardable"
require "openapi3_parser/node_factory/field"

module Openapi3Parser
  module NodeFactory
    module Fields
      class Reference < NodeFactory::Field
        extend Forwardable

        def_delegator :context, :self_referencing?

        def initialize(context, factory)
          super(context, input_type: String, validate: :validate)
          @factory = factory
          @reference = context.input
          @resolved_reference = create_resolved_reference
        end

        def resolved_input
          raise Openapi3Parser::Error, "References can't have a resolved input"
        end

        def referenced_factory
          resolved_reference&.factory
        end

        def node(_node_context)
          raise Openapi3Parser::Error, "Reference fields can't be built as a node"
        end

        private

        attr_reader :reference, :factory, :resolved_reference

        def validate(validatable)
          if !reference_validator.valid?
            validatable.add_errors(reference_validator.errors)
          elsif !reference_resolves?
            validatable.add_error("Reference doesn't resolve to an object")
          else
            validatable.add_errors(resolved_reference&.errors)
          end
        end

        def reference_resolves?
          return true unless referenced_factory.respond_to?(:resolves?)

          referenced_factory.resolves?
        end

        def reference_validator
          @reference_validator ||= Validators::Reference.new(reference)
        end

        def create_resolved_reference
          return unless reference_validator.valid?

          context.resolve_reference(reference,
                                    factory,
                                    recursive: context.self_referencing?)
        end
      end
    end
  end
end
