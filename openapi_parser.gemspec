# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "openapi_parser/version"

Gem::Specification.new do |spec|
  spec.name          = "openapi_parser"
  spec.version       = OpenapiParser::VERSION
  spec.authors       = ["Kevin Dew"]
  spec.email         = ["kevindew@me.com"]

  spec.summary       = "An OpenAPI V3 parser for Ruby"
  spec.description   = "An OpenAPI V3 parser for Ruby"
  spec.homepage      = "https://github.com/kevindew/openapi_parser"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^spec/})
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.6"
  spec.add_development_dependency "rubocop", "~> 0.51"
  spec.add_development_dependency "byebug", "~> 9.1"
end
