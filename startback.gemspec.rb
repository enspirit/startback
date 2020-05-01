$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'startback/version'
require 'date'

def gemspec
  Gem::Specification.new do |s|
    s.version     = Startback::VERSION
    s.date        = Date.today
    s.summary     = "Got Your Ruby Back"
    s.authors     = ["Bernard Lambeau"]
    s.email       = 'blambeau@gmail.com'
    s.homepage    = 'http://www.enspirit.be'
    s.license     = 'MIT'

    s.add_development_dependency 'rspec', ['>= 3.6', '< 4.0']
    s.add_development_dependency 'rspec_junit_formatter', [">= 0.4.1", "< 0.5"]
    s.add_development_dependency "webspicy", [">= 0.15.2", "< 0.16"]
    s.add_development_dependency "rack-test"
    s.add_development_dependency "rake"

    yield(s)
  end
end
