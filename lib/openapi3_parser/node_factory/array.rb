# frozen_string_literal: true

module Openapi3Parser
  module NodeFactory
    class Array
      attr_reader :context, :data, :default, :use_default_on_empty,
                  :value_input_type, :value_factory, :validation

      # rubocop:disable Metrics/ParameterLists
      def initialize(
        context,
        default: [],
        use_default_on_empty: false,
        value_input_type: nil,
        value_factory: nil,
        validate: nil
      )
        @context = context
        @default = default
        @use_default_on_empty = use_default_on_empty
        @value_input_type = value_input_type
        @value_factory = value_factory
        @validation = validate
        @data = build_data(context.input)
      end
      # rubocop:enable Metrics/ParameterLists

      def raw_input
        context.input
      end

      def resolved_input
        @resolved_input ||= build_resolved_input
      end

      def nil_input?
        context.input.nil?
      end

      def valid?
        errors.empty?
      end

      def errors
        @errors ||= ValidNodeBuilder.errors(self)
      end

      def node(node_context)
        data = ValidNodeBuilder.data(self, node_context)
        data.nil? ? nil : build_node(data, node_context)
      end

      def inspect
        %{#{self.class.name}(#{context.source_location.inspect})}
      end

      def use_default?
        return true if nil_input? || !raw_input.is_a?(::Array)
        return false unless use_default_on_empty

        raw_input.empty?
      end

      private

      def build_data(raw_input)
        return if use_default? && default.nil?

        process_data(use_default? ? default : raw_input)
      end

      def process_data(data)
        data.each_with_index.map do |value, i|
          if value_factory
            initialize_value_factory(Context.next_field(context, i, value))
          else
            value
          end
        end
      end

      def initialize_value_factory(field_context)
        if value_factory.is_a?(Class)
          value_factory.new(field_context)
        else
          value_factory.call(field_context)
        end
      end

      def build_node(data, node_context)
        Node::Array.new(data, node_context) if data
      end

      def build_resolved_input
        return unless data

        data.map do |value|
          value.respond_to?(:resolved_input) ? value.resolved_input : value
        end
      end

      class ValidNodeBuilder
        def self.errors(factory)
          new(factory).errors
        end

        def self.data(factory, parent_context)
          new(factory).data(parent_context)
        end

        def initialize(factory)
          @factory = factory
          @validatable = Validation::Validatable.new(factory)
        end

        def errors
          return validatable.collection if factory.nil_input?

          TypeChecker.validate_type(validatable, type: ::Array)
          return validatable.collection if validatable.errors.any?

          collate_errors
          validatable.collection
        end

        def data(parent_context)
          if factory.use_default?
            return factory.default.nil? ? nil : build_node_data(parent_context)
          end

          TypeChecker.raise_on_invalid_type(factory.context, type: ::Array)
          check_values(raise_on_invalid: true)
          validate(raise_on_invalid: true)

          build_node_data(parent_context)
        end

        private_class_method :new

        private

        attr_reader :factory, :validatable

        def build_node_data(parent_context)
          factory.data.each_with_index.map do |value, i|
            next value unless value.respond_to?(:node)

            Node::Placeholder.new(value, i, parent_context)
          end
        end

        def collate_errors
          check_values(raise_on_invalid: false)
          validate(raise_on_invalid: false)

          factory.data.each do |value|
            validatable.add_errors(value.errors) if value.respond_to?(:errors)
          end
        end

        def check_values(raise_on_invalid: false)
          return unless factory.value_input_type

          factory.context.input.each_with_index do |value, index|
            check_field_type(Context.next_field(factory.context, index, value),
                             raise_on_invalid)
          end
        end

        def check_field_type(context, raise_on_invalid)
          if raise_on_invalid
            TypeChecker.raise_on_invalid_type(context,
                                              type: factory.value_input_type)
          else
            TypeChecker.validate_type(validatable,
                                      type: factory.value_input_type,
                                      context: context)
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
            factory.send(:validation, validatable)
          else
            factory.validation&.call(validatable)
          end
        end
      end
    end
  end
end
