# frozen_string_literal: true

require "openapi_parser/node/factory"
require "openapi_parser/node/factory/field_config"

module OpenapiParser
  module Node
    module Factory
      module Object
        include Factory

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
          base.extend(Factory::ClassMethods)
          base.extend(ClassMethods)
          base.class_eval do
            input_type Hash
          end
        end

        private

        def build_node(input, context)
          data = input.each_with_object({}) do |memo, (key, value)|
            memo[key] = value.respond_to?(:node) ? value.node : value
          end
          build_object(data, context)
        end

        def build_object(data, _)
          data
        end
      end
    end
  end
end
