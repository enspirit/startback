$LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
require 'startback/version'
require 'date'

Gem::Specification.new do |s|
  s.name        = 'startback-websocket'
  s.version     = Startback::VERSION
  s.date        = Date.today
  s.summary     = "Websocket on top of Startback"
  s.description = "Websocket on top of the Startback framework"
  s.authors     = ["Bernard Lambeau"]
  s.email       = 'blambeau@gmail.com'
  s.files       = Dir['Gemfile', 'Rakefile', '{lib,spec,tasks,dist}/**/*', 'README*'] & `git ls-files -z`.split("\0")
  s.homepage    = 'https://www.enspirit.be'
  s.license     = 'MIT'

  s.add_runtime_dependency "startback", "= #{Startback::VERSION}"
  s.add_runtime_dependency 'faye-websocket', ['>= 0.11.0', '<= 0.12.0']

  s.add_development_dependency 'rspec', ['>= 3.6', '< 4.0']
  s.add_development_dependency 'rspec_junit_formatter', [">= 0.4.1", "< 0.5"]
  s.add_development_dependency "rake"
  s.add_development_dependency "rack-test"
end
