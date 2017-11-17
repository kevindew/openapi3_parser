# frozen_string_literal: true

module OpenapiParser
  module Validation
    class Error
      attr_reader :namespace, :message

      def initialize(namespace, message)
        @namespace = namespace
        @message = message
      end
    end
  end
end
