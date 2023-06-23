$LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
require 'startback/version'
require 'date'

Gem::Specification.new do |s|
  s.name        = 'startback-web'
  s.version     = Startback::VERSION
  s.date        = Date.today
  s.summary     = "Startback for website"
  s.description = "Startback for website"
  s.authors     = ["Bernard Lambeau"]
  s.email       = 'blambeau@gmail.com'
  s.files       = Dir['Gemfile', 'Rakefile', '{lib,spec,tasks}/**/*', 'README*'] & `git ls-files -z`.split("\0")
  s.homepage    = 'https://www.enspirit.be'
  s.license     = 'MIT'

  s.add_development_dependency 'rspec', ['>= 3.6', '< 4.0']
  s.add_development_dependency 'rspec_junit_formatter', [">= 0.6", "< 0.7"]
  s.add_development_dependency "webspicy", [">= 0.26.0", "< 0.27"]
  s.add_development_dependency "rake"
  s.add_development_dependency "rack-test"

  s.add_runtime_dependency "startback", "= #{Startback::VERSION}"
  s.add_runtime_dependency 'sprockets', [">= 4.0", "< 5.0"]
  s.add_runtime_dependency 'sassc', [">= 2.3", "< 3.0"]
  s.add_runtime_dependency 'sass', [">= 3.7", "< 4.0"]
  s.add_runtime_dependency 'babel-transpiler'
  s.add_runtime_dependency 'uglifier', [">= 4.2", "< 5.0"]
end
