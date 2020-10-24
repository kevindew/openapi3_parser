# frozen_string_literal: true

module Openapi3Parser
  module Validators
    class Email
      # Regex is sourced from HTML specification:
      # https://html.spec.whatwg.org/#e-mail-state-(type=email)
      REGEX = %r{
        \A
        [a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+
        @
        [a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?
        (?:.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*
        \Z
      }x.freeze

      def self.call(input)
        message = %("#{input}" is not a valid email address)
        message unless REGEX.match(input)
      end
    end
  end
end
