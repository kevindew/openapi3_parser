# frozen_string_literal: true

require "openapi3_parser/context"
require "openapi3_parser/node/request_body"
require "openapi3_parser/node_factory/object"
require "openapi3_parser/node_factories/media_type"
require "openapi3_parser/node_factories/map"
require "openapi3_parser/validation/error"
require "openapi3_parser/validators/media_type"

module Openapi3Parser
  module NodeFactories
    class RequestBody
      include NodeFactory::Object

      allow_extensions
      field "description", input_type: String
      field "content", factory: :content_factory, required: true
      field "required", input_type: :boolean, default: false

      private

      def build_object(data, context)
        Node::RequestBody.new(data, context)
      end

      def content_factory(context)
        NodeFactories::Map.new(
          context,
          value_factory: NodeFactories::MediaType,
          validate: ContentValidator
        )
      end

      class ContentValidator
        def self.call(*args)
          new.call(*args)
        end

        def call(input, context)
          # This validation isn't actually mentioned in the spec, but it
          # doesn't seem to make sense if this is an empty hash.
          return "Expected to have at least 1 item" if input.size.zero?

          input.keys.each_with_object([]) do |key, memo|
            message = Validators::MediaType.call(key)
            memo << create_error(key, context, message) if message
          end
        end

        private

        def create_error(key, parent_context, message)
          context = Context.next_field(parent_context, key)
          Validation::Error.new(message, context)
        end
      end
    end
  end
end
