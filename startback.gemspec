$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'startback/version'
require 'date'

Gem::Specification.new do |s|
  s.name        = 'startback'
  s.description = "Yet another ruby backend framework, I'm afraid"
  s.files       = Dir['Rakefile', '{lib,spec,tasks}/**/*', 'README.md', 'VERSION']
  s.version     = Startback::VERSION
  s.date        = Date.today
  s.summary     = "Got Your Ruby Back"
  s.authors     = ["Bernard Lambeau"]
  s.email       = 'blambeau@gmail.com'
  s.homepage    = 'https://www.enspirit.be'
  s.license     = 'MIT'

  s.add_development_dependency 'rspec', ['>= 3.6', '< 4.0']
  s.add_development_dependency 'rspec_junit_formatter', [">= 0.6", "< 0.7"]
  s.add_development_dependency "webspicy", [">= 0.27.0", "< 0.28"]
  s.add_development_dependency "rake"

  s.add_runtime_dependency "sinatra", [">= 3.0", "< 4.0"]
  s.add_runtime_dependency "rack-robustness", [">= 1.0", "< 2.0"]
  s.add_runtime_dependency "finitio", [">= 0.12", "< 0.13"]
  s.add_runtime_dependency "path", [">= 2.1", "< 3.0"]
  s.add_runtime_dependency "http", [">= 5.0", "< 6.0"]
  s.add_runtime_dependency "bunny", [">= 2.14", "< 3.0"]
  s.add_runtime_dependency "nokogiri", [">= 1.11.4", "< 2.0"]
  s.add_runtime_dependency "puma", [">= 6.0.2", "< 7.0"]
  s.add_runtime_dependency "jwt", [">= 2.1", "< 3.0"]
  s.add_runtime_dependency "bmg", [">= 0.21.0", "< 0.24.0"]
  s.add_runtime_dependency "tzinfo", [">= 2.0", "< 3.0"]
  s.add_runtime_dependency "tzinfo-data"
  s.add_runtime_dependency "i18n", [">= 1.0", "< 2.0"]
  s.add_runtime_dependency "mustache", [">= 1.0", "< 2.0"]
  s.add_runtime_dependency "prometheus-client", [">= 2.1"]
end
