# frozen_string_literal: true

require "openapi3_parser/error"
require "openapi3_parser/validation/error"
require "openapi3_parser/validation/error_collection"

module Openapi3Parser
  module NodeFactory
    module ClassMethods
      def input_type(type)
        @input_type = type
      end

      def valid_input_type?(type)
        return true unless @input_type
        type.is_a?(@input_type)
      end

      def expected_input_type
        @input_type
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    EXTENSION_REGEX = /^x-(.*)/

    attr_reader :context

    def initialize(context)
      @context = context
    end

    def valid?
      errors.empty?
    end

    def errors
      @errors ||= build_errors
    end

    def node
      @node ||= build_valid_node
    end

    def nil_input?
      context.input.nil?
    end

    private

    def validate(_input, _context); end

    def validate_input(error_collection)
      add_validation_errors(
        validate(context.input, context),
        error_collection
      )
    end

    def add_validation_errors(errors, error_collection)
      errors = Array(errors)
      errors.each do |error|
        unless error.is_a?(Validation::Error)
          error = Validation::Error.new(context.namespace, error)
        end
        error_collection.append(error)
      end
      error_collection
    end

    def build_errors
      error_collection = Validation::ErrorCollection.new
      return error_collection if nil_input?
      unless valid_type?
        error = Validation::Error.new(
          context.namespace, "Invalid type. #{validate_type}"
        )
        return error_collection.tap { |ec| ec.append(error) }
      end
      validate_input(error_collection)
      error_collection
    end

    def build_valid_node
      if nil_input?
        return default.nil? ? nil : build_node(processed_input)
      end

      unless valid_type?
        raise Openapi3Parser::Error,
              "Invalid type for #{context.stringify_namespace}. "\
              "#{validate_type}"
      end

      validate_before_build
      build_node(processed_input)
    end

    def validate_before_build
      errors = Array(validate(context.input, context))
      return unless errors.any?
      raise Openapi3Parser::Error,
            "Invalid data for #{context.stringify_namespace}. "\
            "#{errors.join(', ')}"
    end

    def valid_type?
      validate_type.nil?
    end

    def validate_type
      valid_type = self.class.valid_input_type?(context.input)
      return "Expected #{self.class.expected_input_type}" unless valid_type
    end

    def processed_input
      @processed_input ||= begin
                             input = nil_input? ? default : context.input
                             process_input(input)
                           end
    end

    def process_input(input)
      input
    end

    def build_node(input)
      input
    end

    def default
      nil
    end

    def extension?(key)
      key.match(EXTENSION_REGEX)
    end
  end
end
