# frozen_string_literal: true

require "openapi3_parser/node/map"

module Openapi3Parser
  module Nodes
    # A map within a OpenAPI document.
    # Very similar to a ruby hash, however this is read only and knows
    # the context of where it sits in an OpenAPI document
    #
    # The contents of the data will be dependent on where this document is in
    # the document hierachy.
    class Map
      include Node::Map
    end
  end
end
