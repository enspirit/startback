require_relative './startback.gemspec'

gemspec do |s|
  s.name        = 'startback'
  s.description = "Yet another ruby backend framework, I'm afraid"
  s.files       = Dir['Rakefile', '{lib,spec,tasks}/**/*', 'README.md', 'VERSION']

  s.add_runtime_dependency "sinatra", [">= 2.0", "< 3.0"]
  s.add_runtime_dependency "rack-robustness", [">= 1.0", "< 2.0"]
  s.add_runtime_dependency "finitio", [">= 0.8", "< 0.9"]
  s.add_runtime_dependency "path", [">= 2.0", "< 3.0"]
  s.add_runtime_dependency "http", [">= 4.4", "< 5.0"]
  s.add_runtime_dependency "bunny", [">= 2.14", "< 3.0"]
  s.add_runtime_dependency "nokogiri", [">= 1.0", "< 2.0"]
  s.add_runtime_dependency "puma", [">= 4.3", "< 5.0"]
  s.add_runtime_dependency "jwt", [">= 2.1", "< 3.0"]
  s.add_runtime_dependency "bmg", [">= 0.16.4", "< 0.17.0"]
  s.add_runtime_dependency "tzinfo", [">= 1.2", "< 2.0"]
  s.add_runtime_dependency "tzinfo-data"
  s.add_runtime_dependency "i18n", [">= 1.0", "< 2.0"]
  s.add_runtime_dependency "mustache", [">= 1.0", "< 2.0"]
end
