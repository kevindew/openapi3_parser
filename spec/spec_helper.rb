# frozen_string_literal: true

require "simplecov"
SimpleCov.start

require "openapi3_parser"
require "webmock/rspec"

files = Dir.glob(File.join(__dir__, "support", "**", "*.rb"))
files.each { |file| require file }

RSpec.configure do |config|
  include Helpers::Context
  include Helpers::Source

  config.disable_monkey_patching!

  config.order = :random

  Kernel.srand config.seed
  WebMock.disable_net_connect!
end
