# frozen_string_literal: true

module OpenapiParser
  module Node
    class FieldConfig
      attr_reader :type, :factory, :required, :default, :validate

      def initialize(
        type: nil,
        factory: nil,
        required: false,
        default: nil,
        validate: nil
      )
        @type = type
        @factory = factory
        @required = required
        @default = default
        @validate = validate
      end
    end
  end
end
