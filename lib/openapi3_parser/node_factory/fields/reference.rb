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
          return unless resolved_reference

          if context.self_referencing?
            RecursiveResolvedInput.new(resolved_reference.factory)
          else
            resolved_reference.resolved_input
          end
        end

        def referenced_factory
          resolved_reference&.factory
        end

        private

        attr_reader :reference, :factory, :resolved_reference

        def build_node(_data, node_context)
          if resolved_reference.nil?
            # this shouldn't happen unless dependant code changes
            raise Openapi3Parser::Error,
                  "can't build node without a resolved reference"
          end

          reference_context = Node::Context.resolved_reference(
            node_context, resolved_reference.factory.context
          )

          resolved_reference.node(reference_context)
        end

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
          return true unless referenced_factory.is_a?(NodeFactory::Reference)

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

        # Used in the place of a hash for resolved input so the value can
        # be looked up at runtime avoiding a recursive loop.
        class RecursiveResolvedInput
          extend Forwardable
          include Enumerable

          def_delegators :value, :each, :[], :keys
          attr_reader :factory

          def initialize(factory)
            @factory = factory
          end

          def value
            @factory.resolved_input
          end
        end
      end
    end
  end
end
