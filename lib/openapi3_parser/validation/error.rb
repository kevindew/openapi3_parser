# frozen_string_literal: true

require "forwardable"

module Openapi3Parser
  module Validation
    # Represents a validation error for an OpenAPI document
    # @attr_reader [String]     message       The error message
    # @attr_reader [Context]    context       The context where this was
    #                                         validated
    # @attr_reader [Class, nil] factory_class The NodeFactory that was being
    #                                         created when this error was found
    class Error
      extend Forwardable

      attr_reader :message, :context, :factory_class

      # @!method source_location
      #   The source file and pointer for where this error occurred
      #   @return [Context::Location]
      def_delegator :context, :source_location

      alias to_s message

      # @param [String]     message
      # @param [Context]    context
      # @param [Class, nil] factory_class
      def initialize(message, context, factory_class = nil)
        @message = message
        @context = context
        @factory_class = factory_class
      end

      # @return [String, nil]
      def for_type
        return unless factory_class
        return "(anonymous)" unless factory_class.name

        factory_class.name.split("::").last
      end

      # @return [String]
      def inspect
        "#{self.class.name}(message: #{message}, context: #{context}, " \
          "for_type: #{for_type})"
      end

      # @return [Boolean]
      def ==(other)
        return false unless other.instance_of?(self.class)

        message == other.message &&
          context == other.context &&
          factory_class == other.factory_class
      end
    end
  end
end
