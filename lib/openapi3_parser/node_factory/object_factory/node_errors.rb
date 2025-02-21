# frozen_string_literal: true

module Openapi3Parser
  module NodeFactory
    module ObjectFactory
      class NodeErrors
        def self.call(factory)
          new.call(factory)
        end

        def call(factory)
          validatable = Validation::Validatable.new(factory)

          return validatable.collection if factory.nil_input? && factory.can_use_default?

          TypeChecker.validate_type(validatable, type: ::Hash)

          validatable.add_errors(Validator.call(factory, raise_on_invalid: false)) if validatable.errors.empty?

          validatable.collection
        end

        private_class_method :new
      end
    end
  end
end
