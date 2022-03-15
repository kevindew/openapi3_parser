# frozen_string_literal: true

module Openapi3Parser
  class OpenapiVersion < Gem::Version
    # Converts the subject of a comparsion to be a OpenapiVersion object
    # to provide shorthand comparisions such as:
    #
    # > OpenapiVersion.new("3.0") > "2.9"
    # => true
    #
    # @return [Boolean]
    def <=>(other)
      super self.class.new(other)
    end
  end
end
