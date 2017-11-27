# frozen_string_literal: true

require "openapi3_parser/error"
require "openapi3_parser/document"

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

    Document.new(parse_input(input))
  end

  # For a given string filename this will read the file and parse it as an
  # OpenAPI document. It will try detect automatically whether the contents
  # are JSON or YAML.
  #
  # @param [String] path Filename of the OpenAPI document
  #
  # @return [Document]
  def self.load_file(path)
    file = File.open(path)
    load(file)
  end

  def self.parse_input(input)
    return input if input.respond_to?(:keys)

    extension = input.respond_to?(:extname) ? input.extname : nil
    contents = input.respond_to?(:read) ? input.read : input

    if extension == ".json" || contents.strip[0] == "{"
      JSON.parse(contents)
    else
      YAML.safe_load(contents, [], [], true)
    end
  end

  private_class_method :parse_input
end
