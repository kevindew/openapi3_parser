# frozen_string_literal: true

module Openapi3Parser
  module Nodes
    class Parameter
      module ParameterLike
        def description
          node_data["description"]
        end

        def required?
          node_data["required"]
        end

        def deprecated?
          node_data["deprecated"]
        end

        def allow_empty_value?
          node_data["allowEmptyValue"]
        end

        def style
          node_data["style"]
        end

        def explode?
          node_data["explode"]
        end

        def allow_reserved?
          node_data["allowReserved"]
        end

        def schema
          node_data["schema"]
        end

        def example
          node_data["example"]
        end

        def examples
          node_data["examples"]
        end

        def content
          node_data["content"]
        end
      end
    end
  end
end
