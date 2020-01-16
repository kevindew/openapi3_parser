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
        @resolved_input ||= build_resolved_input
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
        @errors ||= ObjectFactory::NodeBuilder.errors(self)
      end

      def node(node_context)
        build_node(node_context)
      end

      def can_use_default?
        true
      end

      def default
        nil
      end

      def allowed_fields
        field_configs.keys
      end

      def required_fields
        field_configs.each_with_object([]) do |(key, config), memo|
          memo << key if config.required?
        end
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

      def process_data(raw_data)
        field_configs.each_with_object(raw_data.dup) do |(field, config), memo|
          memo[field] = nil unless memo[field]
          next unless config.factory?

          next_context = Context.next_field(context, field, memo[field])
          memo[field] = config.initialize_factory(next_context, self)
        end
      end

      def build_resolved_input
        return unless data

        data.each_with_object({}) do |(key, value), memo|
          next if value.respond_to?(:nil_input?) && value.nil_input?

          memo[key] = if value.respond_to?(:resolved_input)
                        value.resolved_input
                      else
                        value
                      end
        end
      end

      def build_node(node_context)
        data = ObjectFactory::NodeBuilder.node_data(self, node_context)
        build_object(data, node_context) if data
      end
    end
  end
end
