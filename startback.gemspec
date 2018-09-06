$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'startback/version'

Gem::Specification.new do |s|
  s.name        = 'startback'
  s.version     = Startback::VERSION
  s.date        = '2018-08-30'
  s.summary     = "Got Your Ruby Back"
  s.description = "Yet another ruby backend framework, I'm afraid"
  s.authors     = ["Bernard Lambeau"]
  s.email       = 'blambeau@gmail.com'
  s.files       = Dir['Gemfile', 'Rakefile', '{lib,spec,tasks}/**/*', 'README*'] & `git ls-files -z`.split("\0")
  s.homepage    = 'http://www.enspirit.be'
  s.license     = 'MIT'

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"

  s.add_runtime_dependency "sinatra", "~> 2.0"
  s.add_runtime_dependency "rack-robustness", "~> 1.1"
  s.add_runtime_dependency "finitio", "~> 0.6"
  s.add_runtime_dependency "path", ">= 1.3"
  s.add_runtime_dependency "bmg", "~> 0.14"
  s.add_runtime_dependency "rack-test"
end
