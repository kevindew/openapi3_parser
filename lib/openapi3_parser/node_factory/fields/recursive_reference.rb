# frozen_string_literal: true

require "forwardable"
require "openapi3_parser/node_factory/field"

module Openapi3Parser
  module NodeFactory
    module Fields
      class RecursiveReference < NodeFactory::Field
        def initialize(context, factory)
          super(context, input_type: String, validate: :validate)
          @factory = factory
          @reference = context.input
        end

        def resolved_input
          return unless resolved_reference

          RecursiveResolvedInput.new(resolved_reference.factory)
        end

        private

        attr_reader :reference, :factory

        def build_node(_data, node_context)
          reference_context = Node::Context.resolved_reference(
            node_context,
            resolved_reference.factory.context
          )

          resolved_reference&.node(reference_context)
        end

        def validate(validatable)
          if !reference_validator.valid?
            validatable.add_errors(reference_validator.errors)
          else
            validatable.add_errors(resolved_reference&.errors)
          end
        end

        def reference_validator
          @reference_validator ||= Validators::Reference.new(reference)
        end

        def resolved_reference
          return unless reference_validator.valid?
          # We lazy load the reference here to allow time for it to have been
          # already created as part of initialize on the first instance of this
          # recursive field, without this we can slip into an eternal loop :-(
          @resolved_reference ||= context.resolve_reference(reference, factory)
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
