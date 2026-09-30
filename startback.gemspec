$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'startback/version'
require 'date'

Gem::Specification.new do |s|
  s.name        = 'startback'
  s.description = "Yet another ruby backend framework, I'm afraid"
  s.files       = Dir['Rakefile', '{lib,spec,tasks}/**/*', 'README.md', 'CHANGELOG.md', 'UPGRADING.md', 'VERSION']
  s.version     = Startback::VERSION
  s.date        = Date.today
  s.summary     = "Got Your Ruby Back"
  s.authors     = ["Bernard Lambeau"]
  s.email       = 'blambeau@gmail.com'
  s.homepage    = 'https://www.enspirit.be'
  s.license     = 'MIT'

  # Ruby 3.2 is what the newest dependencies require (bunny 3, finitio 1.0,
  # http 6, json 3, nokogiri 1.19). Ruby 3.1 reached end of life in March
  # 2025, and the test grid never covered it.
  #
  # The test grid covers the whole range the floor allows -- 3.2, 3.3, 3.4
  # and 4.0 -- so this is a tested claim rather than an assumed one.
  s.required_ruby_version = '>= 3.2'

  s.add_development_dependency 'rspec', ['>= 3.6', '< 4.0']
  s.add_development_dependency 'rspec_junit_formatter', [">= 0.6", "< 0.7"]
  s.add_development_dependency "rack-test", [">= 2.0", "< 3.0"]
  s.add_development_dependency "rake"

  # Startback's own code is written against those, and against the major
  # version stated here. Sinatra 4 in particular brings Rack 3, whose
  # response headers are lowercase.
  s.add_runtime_dependency "sinatra", [">= 4.0", "< 5.0"]
  s.add_runtime_dependency "rack-robustness", [">= 2.0", "< 3.0"]
  s.add_runtime_dependency "path", [">= 2.1", "< 3.0"]
  s.add_runtime_dependency "prometheus-client", [">= 2.1"]

  # Startback's own code is written against those, but works with every
  # major version stated here, so that applications are free to pick one.
  s.add_runtime_dependency "bmg", [">= 0.21.0", "< 0.25.0"]
  s.add_runtime_dependency "bunny", [">= 2.14", "< 4.0"]
  s.add_runtime_dependency "finitio", [">= 0.12", "< 2.0"]

  # Startback does not use those itself. They are shipped as a convenience
  # for the applications built on top of it, hence the wide ranges: picking
  # a major version is the application's call, not Startback's.
  s.add_runtime_dependency "http", [">= 5.0", "< 7.0"]
  s.add_runtime_dependency "i18n", [">= 1.0", "< 2.0"]
  s.add_runtime_dependency "jwt", [">= 2.1", "< 4.0"]
  s.add_runtime_dependency "mustache", [">= 1.0", "< 2.0"]
  s.add_runtime_dependency "nokogiri", [">= 1.11.4", "< 2.0"]
  s.add_runtime_dependency "puma", [">= 6.0.2", "< 9.0"]
  s.add_runtime_dependency "tzinfo", [">= 2.0", "< 3.0"]
  s.add_runtime_dependency "tzinfo-data"

  # Those are required by lib/startback.rb but stop being default gems
  # with Ruby 4.0, hence the explicit dependencies.
  s.add_runtime_dependency "benchmark", [">= 0.3", "< 1.0"]
  s.add_runtime_dependency "json", [">= 2.6", "< 4.0"]
  s.add_runtime_dependency "logger", [">= 1.5", "< 2.0"]
  s.add_runtime_dependency "ostruct", [">= 0.6", "< 1.0"]
end
