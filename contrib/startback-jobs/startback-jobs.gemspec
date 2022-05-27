$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'startback/jobs/version'
require 'date'

Gem::Specification.new do |s|
  s.name        = 'startback-jobs'
  s.version     = Startback::Jobs::VERSION
  s.date        = Date.today
  s.summary     = "Asynchronous jobs on top of Startback"
  s.description = "Asynchronous jobs on top of the Startback framework"
  s.authors     = ["Bernard Lambeau"]
  s.email       = 'blambeau@gmail.com'
  s.files       = Dir['Gemfile', 'Rakefile', '{lib,spec,tasks}/**/*', 'README*'] & `git ls-files -z`.split("\0")
  s.homepage    = 'http://www.enspirit.be'
  s.license     = 'MIT'

  s.add_development_dependency 'rspec', ['>= 3.6', '< 4.0']
  s.add_development_dependency 'rspec_junit_formatter', [">= 0.4.1", "< 0.5"]
  s.add_development_dependency "webspicy", [">= 0.20.5", "< 0.21"]
  s.add_development_dependency "rake"
  s.add_development_dependency "rack-test"
  s.add_development_dependency "bmg"

  s.add_runtime_dependency "startback", "~> 0.12.3"
end
