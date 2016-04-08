# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "built/version"

Gem::Specification.new do |s|
  s.name        = "built.io"
  s.version     = Built::VERSION
  s.summary     = "The built.io Ruby SDK"
  s.description = <<-DOC
    built.io is a Backend-as-a-Service (BaaS).

    This is a Ruby SDK that provides a convenient API.
  DOC
  s.authors     = ["Suvish Thoovamalayil", "Dan Matthews"]
  s.email       = "dan@matthews.es"
  s.homepage    = "https://github.com/dmvt/built.io-ruby-sdk"
  s.files       = Dir["lib/**/*"] + %w(MIT-LICENSE README.md)
  s.license     = "MIT"

  s.add_dependency "i18n"
  s.add_dependency "faraday", "~> 0.9"
  s.add_dependency "oj", "~> 2"
  s.add_dependency "inflecto"

  # TODO: bring back testing
  # s.add_development_dependency "rspec"
  s.add_development_dependency "bundler"
  s.add_development_dependency "pry"
  s.add_development_dependency "rake", "~> 11"

  s.required_ruby_version = ">= 2.0.0"
end
