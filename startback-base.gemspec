require_relative './startback.gemspec'

gemspec do |s|
  s.name        = 'startback'
  s.description = "Yet another ruby backend framework, I'm afraid"
  s.files       = Dir['Rakefile', '{lib,spec,tasks}/**/*', 'README.md', 'VERSION']

  s.add_runtime_dependency "sinatra", "~> 2.0"
  s.add_runtime_dependency "rack-robustness", "~> 1.1"
  s.add_runtime_dependency "finitio", ">= 0.8"
  s.add_runtime_dependency "path", ">= 2.0"
  s.add_runtime_dependency "nokogiri", "~> 1"
  s.add_runtime_dependency "puma", "~> 4.3"
end
