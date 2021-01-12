# frozen_string_literal: true

module Openapi3Parser
  module Validators
    class Url
      def self.call(input)
        URI.parse(input) && nil
      rescue URI::InvalidURIError
        %("#{input}" is not a valid URL)
      end
    end
  end
end
