# frozen_string_literal: true

require "forwardable"
require "openapi3_parser/node_factory/field"

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
          return unless reference_resolver

          if in_recursive_loop?
            RecursiveResolvedInput.new(reference_context)
          else
            reference_resolver.resolved_input
          end
        end

        def in_recursive_loop?
          context.source_location == reference_context&.source_location
        end

        def reference_context
          context.referenced_by
        end

        private

        attr_reader :reference, :factory, :reference_resolver

        def build_node(_data)
          reference_resolver&.node
        end

        def validate(validatable)
          if !reference_validator.valid?
            validatable.add_errors(reference_validator.errors)
          else
            validatable.add_errors(reference_resolver&.errors)
          end
        end

        def reference_validator
          @reference_validator ||= Validators::Reference.new(reference)
        end

        def create_reference_resolver
          return unless reference_validator.valid?
          context.register_reference(reference, factory)
        end

        # Used in the place of a hash for resolved input so the value can
        # be looked up at runtime avoiding a recursive loop.
        class RecursiveResolvedInput
          extend Forwardable
          include Enumerable

          def_delegators :resolved_input, :each, :[], :keys
          attr_reader :context

          def initialize(context)
            @context = context
          end

          def resolved_input
            context.resolved_input
          end
        end
      end
    end
  end
end
