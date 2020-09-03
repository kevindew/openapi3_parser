# frozen_string_literal: true

module Openapi3Parser
  module NodeFactory
    class Map
      attr_reader :allow_extensions, :context, :data, :default,
                  :value_input_type, :value_factory,
                  :validation

      # rubocop:disable Metrics/ParameterLists
      def initialize(
        context,
        allow_extensions: false,
        default: {},
        value_input_type: nil,
        value_factory: nil,
        validate: nil
      )
        @context = context
        @allow_extensions = allow_extensions
        @default = default
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

      private

      def build_data(raw_input)
        use_default = nil_input? || !raw_input.is_a?(::Hash)
        return if use_default && default.nil?

        process_data(use_default ? default : raw_input)
      end

      def process_data(data)
        data.each_with_object({}) do |(key, value), memo|
          memo[key] = if EXTENSION_REGEX =~ key.to_s || !value_factory
                        value
                      else
                        next_context = Context.next_field(context, key)
                        initialize_value_factory(next_context)
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
        Node::Map.new(data, node_context) if data
      end

      def build_resolved_input
        return unless data

        data.transform_values do |value|
          if value.respond_to?(:resolved_input)
            value.resolved_input
          else
            value
          end
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

          TypeChecker.validate_type(validatable, type: ::Hash)
          return validatable.collection if validatable.errors.any?

          collate_errors
          validatable.collection
        end

        def data(parent_context)
          return default_value if factory.nil_input?

          TypeChecker.raise_on_invalid_type(factory.context, type: ::Hash)
          check_keys(raise_on_invalid: true)
          check_values(raise_on_invalid: true)
          validate(raise_on_invalid: true)

          factory.data.each_with_object({}) do |(key, value), memo|
            memo[key] = if value.respond_to?(:node)
                          Node::Placeholder.new(value, key, parent_context)
                        else
                          value
                        end
          end
        end

        private_class_method :new

        private

        attr_reader :factory, :validatable

        def collate_errors
          check_keys(raise_on_invalid: false)
          check_values(raise_on_invalid: false)
          validate(raise_on_invalid: false)

          factory.data.each_value do |value|
            validatable.add_errors(value.errors) if value.respond_to?(:errors)
          end
        end

        def default_value
          if factory.nil_input? && factory.default.nil?
            nil
          else
            factory.data
          end
        end

        def check_keys(raise_on_invalid: false)
          if raise_on_invalid
            TypeChecker.raise_on_invalid_keys(factory.context,
                                              type: ::String)
          else
            TypeChecker.validate_keys(validatable,
                                      type: ::String,
                                      context: factory.context)
          end
        end

        def check_values(raise_on_invalid: false)
          return unless factory.value_input_type

          factory.context.input.each do |key, value|
            next if factory.allow_extensions && key.to_s =~ EXTENSION_REGEX

            check_field_type(Context.next_field(factory.context, key, value),
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
            factory.send(factory.validation, validatable)
          else
            factory.validation&.call(validatable)
          end
        end
      end
    end
  end
end
