# frozen_string_literal: true

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.warnings = true

  config.order = :random

  Kernel.srand config.seed
end
