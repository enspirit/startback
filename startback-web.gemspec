require_relative './startback.gemspec'

gemspec do |s|
  s.name        = 'startback-web'
  s.description = "Web variant of startback"

  s.add_runtime_dependency 'startback', "= #{Startback::VERSION}"
  s.add_runtime_dependency 'sprockets', [">= 4.0", "< 5.0"]
  s.add_runtime_dependency 'sassc', [">= 2.3", "< 3.0"]
  s.add_runtime_dependency 'sass', [">= 3.7", "< 4.0"]
  s.add_runtime_dependency 'babel-transpiler'
  s.add_runtime_dependency 'uglifier', [">= 3.1", "< 4.0"]
end
