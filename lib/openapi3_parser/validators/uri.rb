# frozen_string_literal: true

module Openapi3Parser
  module Validators
    class Uri
      def self.call(input)
        URI.parse(input) && nil
      rescue URI::InvalidURIError
        %("#{input}" is not a valid URI)
      end
    end
  end
end
