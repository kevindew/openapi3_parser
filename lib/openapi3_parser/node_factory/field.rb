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
        @errors ||= Validator.call(self)
      end

      def node(node_context)
        Validator.call(self, raise_on_invalid: true)
        data_to_use = nil_input? && default.nil? ? nil : data
        data_to_use.nil? ? nil : build_node(data, node_context)
      end

      def inspect
        %{#{self.class.name}(#{context.source_location.inspect})}
      end

      def build_node(data, _node_context)
        data
      end

      class Validator
        private_class_method :new

        def self.call(*args, **kwargs)
          new(*args, **kwargs).call
        end

        def initialize(factory, raise_on_invalid: false)
          @factory = factory
          @raise_on_invalid = raise_on_invalid
          @validatable = Validation::Validatable.new(factory)
        end

        def call
          return validatable.collection if factory.nil_input?

          if raise_on_invalid
            TypeChecker.raise_on_invalid_type(factory.context, type: factory.input_type)
          else
            TypeChecker.validate_type(validatable, type: factory.input_type)
          end

          return validatable.collection if validatable.errors.any?

          validate
          validatable.collection
        end

        private

        attr_reader :factory, :validatable, :raise_on_invalid

        def validate
          run_validation

          return if !raise_on_invalid || validatable.errors.empty?

          first_error = validatable.errors.first
          raise Openapi3Parser::Error::InvalidData,
                "Invalid data for #{first_error.context.location_summary}: " \
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
