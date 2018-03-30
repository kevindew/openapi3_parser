# frozen_string_literal: true

require "rspec/expectations"

RSpec::Matchers.define :have_validation_error do |expected_location|
  match do |actual|
    errors_hash = actual.errors.to_h
    locations = errors_hash.keys

    return false unless locations.include?(expected_location)
    return true unless expected_message

    errors_hash[expected_location].any? do |message|
      if expected_message.is_a?(Regexp)
        expected_message.match(message)
      else
        message == expected_message
      end
    end
  end

  chain :with_message, :expected_message
end
