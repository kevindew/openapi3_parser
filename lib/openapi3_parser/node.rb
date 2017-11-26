# frozen_string_literal: true

require "openapi3_parser/node/field_config"

module Openapi3Parser
  module Node
    module ClassMethods
      def field(name, **options)
        @field_configs ||= {}
        @field_configs[name] = FieldConfig.new(options)
      end

      def field_configs
        @field_configs || {}
      end

      def allow_extensions
        @allow_extensions = true
      end

      def disallow_extensions
        @allow_extensions = false
      end

      def allowed_extensions?
        @allow_extensions == true
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    EXTENSION_REGEX = /^x-(.*)/

    attr_reader :input, :context, :fields

    def initialize(input, context)
      @input = input
      @context = context
      @fields = build_fields(input)
    end

    def [](value)
      fields[value]
    end

    def extension(value)
      fields["x-#{value}"]
    end

    private

    def build_fields(input)
      check_for_unexpected_fields(input)
      create_fields(input)
    end

    def check_for_unexpected_fields(input)
      allowed_fields = field_configs.keys
      remaining_fields = input.keys - allowed_fields
      return if remaining_fields.empty?

      if allowed_extensions?
        remaining_fields.reject! { |key| key =~ EXTENSION_REGEX }
      end

      return if remaining_fields.empty?
      raise Error,
            "Unexpected attributes for #{context.stringify_namespace}: "\
            "#{remaining_fields.join(', ')}"
    end

    def create_fields(input)
      check_required(input)
      check_types(input)
      fields = field_configs.each_with_object({}) do |(field, config), memo|
        next_context = context.next_namespace(field)
        memo[field] = config.build(input[field], self, next_context)
      end
      extensions = input.select { |(k, _)| k =~ EXTENSION_REGEX }
      fields.merge(extensions)
    end

    def check_required(input)
      missing = field_configs.reject do |field, config|
        config.valid_presence?(input[field])
      end

      return if missing.empty?
      raise Error,
            "Missing required fields for #{context.stringify_namespace}: "\
              "#{missing.keys}"
    end

    def check_types(input)
      invalid = field_configs.reject do |field, config|
        config.valid_input_type?(input[field], self)
      end

      return if invalid.empty?
      raise Error,
            "Invalid fields for #{context.stringify_namespace}: "\
              "#{invalid.keys}"
    end

    def allowed_extensions?
      self.class.allowed_extensions?
    end

    def field_configs
      self.class.field_configs || {}
    end
  end
end
