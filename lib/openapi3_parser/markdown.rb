# frozen_string_literal: true

require "commonmarker"

module Openapi3Parser
  # Wrapper around a gem to render markdown, used a single place for options
  # and handling the gem
  module Markdown
    # @param  [String]  text
    # @return [String]
    def self.to_html(text)
      Commonmarker.to_html(text)
    end
  end
end
