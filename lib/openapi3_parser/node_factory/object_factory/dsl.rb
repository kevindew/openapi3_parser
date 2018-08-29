# frozen_string_literal: true

require "ostruct"
require "openapi3_parser/node_factory/object_factory/field_config"

module Openapi3Parser
  module NodeFactory
    module ObjectFactory
      module Dsl
        def field(name, **options)
          @field_configs ||= {}
          @field_configs[name] = FieldConfig.new(options)
        end

        def field_configs
          @field_configs ||= {}
        end

        def allow_extensions
          @allow_extensions = true
        end

        def allowed_extensions?
          if instance_variable_defined?(:@allow_extensions)
            @allow_extensions == true
          else
            false
          end
        end

        def mutually_exclusive(*fields, required: false)
          @mutually_exclusive_fields ||= []
          @mutually_exclusive_fields << OpenStruct.new(
            fields: fields, required: required
          )
        end

        def mutually_exclusive_fields
          @mutually_exclusive_fields ||= []
        end

        def validate(*items, &block)
          @validations ||= []
          @validations = @validations.concat(items)
          @validations << block if block
        end

        def validations
          @validations ||= []
        end
      end
    end
  end
end
