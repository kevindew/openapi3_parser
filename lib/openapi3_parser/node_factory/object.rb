# frozen_string_literal: true

require "forwardable"
require "openapi3_parser/node_factory/object_factory/dsl"

module Openapi3Parser
  module NodeFactory
    class Object
      extend Forwardable
      extend ObjectFactory::Dsl

      def_delegators "self.class",
                     :field_configs,
                     :extension_regex,
                     :allowed_extensions?,
                     :mutually_exclusive_fields,
                     :allowed_default?,
                     :validations

      attr_reader :context, :data

      def self.object_type
        to_s
      end

      def initialize(context)
        @context = context
        @data = build_data(context.input)
      end

      def resolved_input
        @resolved_input ||= ObjectFactory::ResolvedInputBuilder.call(self)
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

      def errors
        @errors ||= ObjectFactory::NodeErrors.call(self)
      end

      def node(node_context)
        node_builder = ObjectFactory::NodeBuilder.new(self, node_context)
        node_builder.build_node
      end

      def build_node(_data, _node_context)
        raise Error, "Expected to be implemented in child class"
      end

      def can_use_default?
        true
      end

      def default
        nil
      end

      def allowed_fields
        allowed_field_configs.keys
      end

      def required_fields
        allowed_field_configs.each_with_object([]) do |(key, config), memo|
          memo << key if config.required?(context, self)
        end
      end

      def inspect
        %{#{self.class.name}(#{context.source_location.inspect})}
      end

      private

      def allowed_field_configs
        field_configs.select { |_, fc| fc.allowed?(context, self) }
      end

      def build_data(raw_input)
        use_default = nil_input? || !raw_input.is_a?(::Hash)
        return if use_default && default.nil?

        process_data(use_default ? default : raw_input)
      end

      def process_data(raw_data)
        allowed_field_configs.each_with_object(raw_data.dup) do |(field, config), memo|
          memo[field] = nil unless memo[field]
          next unless config.factory?

          next_context = Context.next_field(context, field, memo[field])
          memo[field] = config.initialize_factory(next_context, self)
        end
      end
    end
  end
end
