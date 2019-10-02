$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'startback/version'
require 'date'

Gem::Specification.new do |s|
  s.name        = 'startback'
  s.version     = Startback::VERSION
  s.date        = Date.today
  s.summary     = "Got Your Ruby Back"
  s.description = "Yet another ruby backend framework, I'm afraid"
  s.authors     = ["Bernard Lambeau"]
  s.email       = 'blambeau@gmail.com'
  s.files       = Dir['Gemfile', 'Rakefile', '{lib,spec,tasks}/**/*', 'README*'] & `git ls-files -z`.split("\0")
  s.homepage    = 'http://www.enspirit.be'
  s.license     = 'MIT'

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rack-test"

  s.add_development_dependency "sprockets", "~> 4.0.0.beta8"
  s.add_development_dependency "babel-transpiler"

  s.add_runtime_dependency "sinatra", "~> 2.0"
  s.add_runtime_dependency "rack-robustness", "~> 1.1"
  s.add_runtime_dependency "finitio", ">= 0.7"
  s.add_runtime_dependency "path", ">= 1.3"
end
