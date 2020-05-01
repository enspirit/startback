require_relative './startback.gemspec'

gemspec do |s|
  s.name        = 'startback-api'
  s.description = "Api variant of startback"

  s.add_runtime_dependency 'startback', "= #{Startback::VERSION}"
end
