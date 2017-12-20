# frozen_string_literal: true

require "webmock/rspec"

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.warnings = false

  config.order = :random

  Kernel.srand config.seed

  WebMock.disable_net_connect!
end
