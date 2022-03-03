# coding: utf-8

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fastlane/plugin/localize/version"

Gem::Specification.new do |spec|
  spec.name = "fastlane-plugin-localize"
  spec.version = Fastlane::Localize::VERSION
  spec.author = "Wolfgang Lutz"
  spec.email = "wlut@num42.de"

  spec.summary = "Searches the code for extractable strings and allows interactive extraction to .strings file."
  spec.homepage = "https://github.com/num42/fastlane-plugin-localize"
  spec.license = "MIT"

  spec.files = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.5"

  spec.add_development_dependency("bundler")
  spec.add_development_dependency("fastlane", ">= 2.204.3")
  spec.add_development_dependency("pry")
  spec.add_development_dependency("rake")
  spec.add_development_dependency("rspec")
  spec.add_development_dependency("rspec_junit_formatter")
  spec.add_development_dependency("rubocop", "1.12.1")
  spec.add_development_dependency("rubocop-performance")
  spec.add_development_dependency("rubocop-require_tools")
  spec.add_development_dependency("simplecov")
end
