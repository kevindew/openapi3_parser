# frozen_string_literal: true

require "openapi_parser/error"
require "openapi_parser/document"

require "yaml"
require "json"

module OpenapiParser
  def self.load(input)
    # working_directory ||= if input.respond_to?(:read)
    #                         File.dirname(input)
    #                       else
    #                         Dir.pwd
    #                       end

    Document.new(parse_input(input))
  end

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
