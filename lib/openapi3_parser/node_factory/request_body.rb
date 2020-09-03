# frozen_string_literal: true

require "openapi3_parser/node_factory/object"

module Openapi3Parser
  module NodeFactory
    class RequestBody < NodeFactory::Object
      allow_extensions
      field "description", input_type: String
      field "content", factory: :content_factory, required: true
      field "required", input_type: :boolean, default: false

      private

      def build_object(data, context)
        Node::RequestBody.new(data, context)
      end

      def content_factory(context)
        NodeFactory::Map.new(
          context,
          value_factory: NodeFactory::MediaType,
          validate: ContentValidator
        )
      end

      class ContentValidator
        def self.call(*args)
          new.call(*args)
        end

        def call(validatable)
          # This validation isn't actually mentioned in the spec, but it
          # doesn't seem to make sense if this is an empty hash.
          return validatable.add_error("Expected to have at least 1 item") if validatable.input.size.zero?

          validatable.input.each_key do |key|
            message = Validators::MediaType.call(key)
            next unless message

            context = Context.next_field(validatable.context, key)
            validatable.add_error(message, context)
          end
        end
      end
    end
  end
end
