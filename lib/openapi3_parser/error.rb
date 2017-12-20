# frozen_string_literal: true

module Openapi3Parser
  class Error < ::RuntimeError
    class InaccessibleInput < Error; end
    class UnparsableInput < Error; end
  end
end
