# frozen_string_literal: true

require "openapi3_parser"
require "webmock/rspec"
require "support/matchers/have_validation_error"

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.order = :random

  Kernel.srand config.seed

  WebMock.disable_net_connect!
end
