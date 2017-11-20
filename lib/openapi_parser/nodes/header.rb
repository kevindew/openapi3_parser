# frozen_string_literal: true

require "openapi_parser/node/object"
require "openapi_parser/nodes/parameter/parameter_like"

module OpenapiParser
  module Nodes
    class Header
      include Node::Object
      include Parameter::ParameterLike
    end
  end
end
