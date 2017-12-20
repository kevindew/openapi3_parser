# frozen_string_literal: true

require "openapi3_parser/error"
require "openapi3_parser/document"
require "openapi3_parser/source_input/raw"
require "openapi3_parser/source_input/file"
require "openapi3_parser/source_input/url"

require "yaml"
require "json"

module Openapi3Parser
  # For a variety of inputs this will construct an OpenAPI document. For a
  # String/File input it will try to determine if the input is JSON or YAML.
  #
  # @param [String, Hash, File] input Source for the OpenAPI document
  #
  # @return [Document]
  def self.load(input)
    # working_directory ||= if input.respond_to?(:read)
    #                         File.dirname(input)
    #                       else
    #                         Dir.pwd
    #                       end

    Document.new(SourceInput::Raw.new(input))
  end

  # For a given string filename this will read the file and parse it as an
  # OpenAPI document. It will try detect automatically whether the contents
  # are JSON or YAML.
  #
  # @param [String] path Filename of the OpenAPI document
  #
  # @return [Document]
  def self.load_file(path)
    Document.new(SourceInput::File.new(path))
  end

  def self.load_url(url)
    Document.new(SourceInput::Url.new(url.to_s))
  end
end
