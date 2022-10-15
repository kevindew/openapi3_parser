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

        def allow_extensions(regex: EXTENSION_REGEX, &block)
          @extension_regex = regex
          @allowed_extensions = block || true
        end

        def allowed_extensions?(context)
          @allowed_extensions ||= nil

          allowed = if @allowed_extensions.respond_to?(:call)
                      @allowed_extensions.call(context)
                    else
                      @allowed_extensions
                    end

          !!allowed
        end

        def extension_regex
          @extension_regex ||= nil
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
