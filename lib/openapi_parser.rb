# frozen_string_literal: true

require "openapi_parser/factory"
require "openapi_parser/document"
require "openapi_parser/node"
Dir[File.join(__dir__, "openapi_parser", "node", "*.rb")].each { |f| require f }

require "yaml"
require "json"

module OpenapiParser
  def self.load(input, working_directory: nil)
    working_directory ||= if input.respond_to?(:read)
                            File.dirname(input)
                          else
                            Dir.pwd
                          end

    Factory.new(parse_input(input), working_directory: working_directory)
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
