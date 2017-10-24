# frozen_string_literal: true

module OpenapiParser
  class Node
    class << self
      attr_reader :attribute_configs

      def attribute(field, **options)
        @attribute_configs ||= {}
        opts = {
          field_name: field.to_s,
          required: false,
          string: false,
          object: false,
          build: nil,
        }.merge(options)

        # @TODO maybe this attribute config stuff should be a class to
        # encapsulate the logic?

        @attribute_configs[field] = opts

        self.send(:define_method, field) do
          @attributes[opts[:field_name]]
        end
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

    EXTENSION_REGEX = /^x-(.*)/

    # using SnakeCase
    attr_reader :input, :document, :namespace, :attributes, :extensions

    def initialize(input, document, namespace = [])
      @input = input
      @document = document
      @namespace = namespace.freeze
      @attributes = build_attributes(input)
      @extensions = allowed_extensions? ? extract_extensions(input) : {}
    end

    def [](value)
      attributes[value]
    end

    def extension(value)
      extensions[value]
    end

    def stringify_namespace(append = nil)
      ns = append ? namespace + [append] : namespace
      if ns.empty?
        "root"
      else
        ns.join("/")
      end
    end

    private

    def build_attributes(input)
      check_for_unexpected_attributes(input)
      create_attributes(input)
    end

    def check_for_unexpected_attributes(input)
      allowed_attributes = attribute_configs.map { |_, c| c[:field_name] }
      remaining_attributes = input.keys - allowed_attributes
      return if remaining_attributes.empty?

      if allowed_extensions?
        remaining_attributes.reject! { |key| key =~ EXTENSION_REGEX }
      end

      unless remaining_attributes.empty?
        raise Error,
          "Unexpected attributes for #{stringify_namespace}: "\
          "#{remaining_attributes.join(', ')}"
      end
    end

    def create_attributes(input)
      attribute_configs.each_with_object({}) do |(field, config), memo|
        required_attribute(input, config)
        memo[config[:field_name]] = build_attribute(input, config)
      end
    end

    def required_attribute(input, config)
      if input[config[:field_name]].nil? && config[:required]
        raise Error,
          "Missing required attributes for #{stringify_namespace}: "\
          "#{config[:field_name]}"
      end
    end

    def build_attribute(input, config)
      field_name = config[:field_name]
      attribute = input[field_name]

      return if attribute.nil?

      if config[:string] && !attribute.is_a?(String)
        raise Error,
          "#{stringify_namespace(field_name)} is expected to be a string"
      end

      if config[:object] && !attribute.respond_to?(:keys)
        raise Error,
          "#{stringify_namespace(field_name)} is expected to be an object"
      end

      if config[:build].is_a?(Proc)
        config[:build].call(attribute, document, namespace + [field_name])
      elsif config[:build]
        send(config[:build], attribute, document, namespace + [field_name])
      else
        input[field_name]
      end
    end

    def allowed_extensions?
      self.class.allowed_extensions?
    end

    def attribute_configs
      self.class.attribute_configs || {}
    end

    def extract_extensions(input)
      input.each_with_object({}) do |(key, value), memo|
        memo[Regexp.last_match[1]] = value if key =~ EXTENSION_REGEX
      end
    end
  end
end
