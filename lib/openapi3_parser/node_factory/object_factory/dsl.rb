# frozen_string_literal: true

require "openapi3_parser/node_factory/object_factory/field_config"

module Openapi3Parser
  module NodeFactory
    module ObjectFactory
      module Dsl
        MutuallyExclusiveField = Struct.new(:fields, :required, keyword_init: true)

        def field(name, **options)
          @field_configs ||= {}
          @field_configs[name] = FieldConfig.new(**options)
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
          @mutually_exclusive_fields << MutuallyExclusiveField.new(
            fields: fields,
            required: required
          )
        end

        def mutually_exclusive_fields
          @mutually_exclusive_fields ||= []
        end

        def validate(*items, &block)
          @validations ||= []
          @validations.concat(items)
          @validations << block if block
        end

        def validations
          @validations ||= []
        end
      end
    end
  end
end
