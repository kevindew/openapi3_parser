# frozen_string_literal: true

module Openapi3Parser
  module Validation
    class Error
      attr_reader :message, :context, :factory_class

      def initialize(message, context, factory_class = nil)
        @message = message
        @context = context
        @factory_class = factory_class
      end
    end
  end
end
