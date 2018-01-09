# frozen_string_literal: true

module Openapi3Parser
  class Error < ::RuntimeError
    class InaccessibleInput < Error; end
    class UnparsableInput < Error; end
    class ImmutableObject < Error; end
  end
end
