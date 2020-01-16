# frozen_string_literal: true

module Openapi3Parser
  module NodeFactory
    class Field
      attr_reader :context, :input_type, :validation

      def initialize(context, input_type: nil, validate: nil)
        @context = context
        @input_type = input_type
        @validation = validate
      end

      def data
        context.input
      end

      def resolved_input
        context.input
      end

      def raw_input
        context.input
      end

      def nil_input?
        context.input.nil?
      end

      def valid?
        errors.empty?
      end

      def default
        nil
      end

      def errors
        @errors ||= ValidNodeBuilder.errors(self)
      end

      def node(node_context)
        data = ValidNodeBuilder.data(self)
        data.nil? ? nil : build_node(data, node_context)
      end

      def inspect
        %{#{self.class.name}(#{context.source_location.inspect})}
      end

      private

      def build_node(data, _node_context)
        data
      end

      class ValidNodeBuilder
        def self.errors(factory)
          new(factory).errors
        end

        def self.data(factory)
          new(factory).data
        end

        def initialize(factory)
          @factory = factory
          @validatable = Validation::Validatable.new(factory)
        end

        def errors
          return validatable.collection if factory.nil_input?

          TypeChecker.validate_type(validatable, type: factory.input_type)
          return validatable.collection if validatable.errors.any?

          validate(raise_on_invalid: false)
          validatable.collection
        end

        def data
          return default_value if factory.nil_input?

          TypeChecker.raise_on_invalid_type(factory.context,
                                            type: factory.input_type)
          validate(raise_on_invalid: true)
          factory.data
        end

        private_class_method :new

        private

        attr_reader :factory, :validatable

        def default_value
          if factory.nil_input? && factory.default.nil?
            nil
          else
            factory.data
          end
        end

        def validate(raise_on_invalid: false)
          run_validation

          return if !raise_on_invalid || validatable.errors.empty?

          first_error = validatable.errors.first
          raise Openapi3Parser::Error::InvalidData,
                "Invalid data for #{first_error.context.location_summary}: "\
                "#{first_error.message}"
        end

        def run_validation
          if factory.validation.is_a?(Symbol)
            factory.send(factory.validation, validatable)
          else
            factory.validation&.call(validatable)
          end
        end
      end
    end
  end
end
