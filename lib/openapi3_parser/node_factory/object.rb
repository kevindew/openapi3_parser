# frozen_string_literal: true

require "forwardable"

require "openapi3_parser/context"
require "openapi3_parser/node_factory/object_factory/dsl"
require "openapi3_parser/node_factory/object_factory/node_builder"

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

      def initialize(context)
        @context = context
        data = nil_input? ? default : context.input
        @data = data.nil? ? nil : process_data(data)
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

      def node
        @node ||= build_node
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

      private

      def process_data(raw_data)
        field_configs.each_with_object(raw_data.dup) do |(field, config), memo|
          memo[field] = nil unless memo[field]
          next unless config.factory?
          next_context = Context.next_field(context, field)
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

      def build_node
        data = ObjectFactory::NodeBuilder.node_data(self)
        build_object(data, context)
      end
    end
  end
end
