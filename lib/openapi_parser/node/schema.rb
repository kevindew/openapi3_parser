# frozen_string_literal: true

module OpenapiParser
  class Node
    class Schema < Node
      allow_extensions

      attribute :title, string: true
      attribute :multiple_of, field_name: "multipleOf"
      attribute :maximum
      attribute :exclusive_maximum, field_name: "exclusiveMaximum"
      attribute :minimum
      attribute :exclusive_minimum, field_name: "exclusiveMinimum"
      attribute :max_length, field_name: "maxLength"
      attribute :min_length, field_name: "minLength"
      attribute :pattern, string: true
      attribute :max_items, field_name: "maxItems"
      attribute :min_items, field_name: "minItems"
      attribute :unique_items, field_name: "uniqueItems"
      attribute :max_properties, field_name: "maxProperties"
      attribute :min_properties, field_name: "minProperties"
      attribute :required
      attribute :enum
      attribute :type, string: true

      attribute :all_of, field_name: "allOf"
      attribute :one_of, field_name: "oneOf"
      attribute :any_of, field_name: "anyOf"
      attribute :items, object: true
      attribute :properties, object: true
      attribute :additional_properties, field_name: "additionalProperties"
      attribute :description, string: true
      attribute :format, string: true
      attribute :default

      attribute :nullable
      attribute :discriminator
      attribute :read_only, field_name: "readOnly"
      attribute :write_only, field_name: "writeOnly"
      attribute :xml
      attribute :external_docs, field_name: "externalDocs"
      attribute :example

      attribute :deprecated
    end
  end
end
