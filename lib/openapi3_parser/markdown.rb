# frozen_string_literal: true

require "commonmarker"

module Openapi3Parser
  # Wrapper around a gem to render markdown, used a single place for options
  # and handling the gem
  module Markdown
    # @param  [String]  text
    # @return [String]
    def self.to_html(text)
      CommonMarker.render_doc(text).to_html
    end
  end
end
