$LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
require 'startback/version'
require 'date'

Gem::Specification.new do |s|
  s.name        = 'startback-jobs'
  s.version     = Startback::VERSION
  s.date        = Date.today
  s.summary     = "Asynchronous jobs on top of Startback"
  s.description = "Asynchronous jobs on top of the Startback framework"
  s.authors     = ["Bernard Lambeau"]
  s.email       = 'blambeau@gmail.com'
  s.files       = Dir['Gemfile', 'Rakefile', '{lib,spec,tasks}/**/*', 'README*'] & `git ls-files -z`.split("\0")
  s.homepage    = 'https://www.enspirit.be'
  s.license     = 'MIT'

  # Ruby 3.2 is what the newest dependencies require (bunny 3, finitio 1.0,
  # http 6, json 3, nokogiri 1.19). Ruby 3.1 reached end of life in March
  # 2025, and the test grid never covered it.
  s.required_ruby_version = '>= 3.2'

  s.add_development_dependency 'rspec', ['>= 3.6', '< 4.0']
  s.add_development_dependency 'rspec_junit_formatter', [">= 0.6", "< 0.7"]
  s.add_development_dependency "webspicy", [">= 1.0", "< 2.0"]
  s.add_development_dependency "rake"
  s.add_development_dependency "rack-test"
  s.add_development_dependency "bmg"

  s.add_runtime_dependency "startback", "= #{Startback::VERSION}"
end
