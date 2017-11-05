# frozen_string_literal: true

module OpenapiParser
  module Node
    class FieldConfig
      attr_reader :required, :input_type, :build_func, :default

      def initialize(required: false, input_type: nil, build: nil, default: nil)
        @required = required
        @input_type = input_type
        @default = default
        @build_func = build
      end

      def build(input, node, context)
        value = determine_value(input, node, context)
        value.nil? ? determine_default(node) : value
      end

      def valid_presence?(input)
        !required || !input.nil?
      end

      # rubocop:disable Metrics/AbcSize
      def valid_input_type?(input, node)
        return true if !input_type || input.nil?
        return [true, false].include?(input) if input_type == :boolean
        return input_type.call(input) if input_type.is_a?(Proc)
        return node.send(input_type, input) if input_type.is_a?(Symbol)
        input.is_a?(input_type)
      end
      # rubocop:enable Metrics/AbcSize

      private

      def determine_value(input, node, context)
        return if input.nil?
        return build_func.call(input, context) if build_func.is_a?(Proc)
        return node.send(build_func, input, context) if build_func
        input
      end

      def determine_default(node)
        return default.call if default.is_a?(Proc)
        return node.send(default) if default.is_a?(Symbol)
        default
      end
    end
  end
end
