require_relative './startback.gemspec'

gemspec do |s|
  s.name        = 'startback-engine'
  s.description = "Engine variant of startback"

  s.add_runtime_dependency 'startback', "= #{Startback::VERSION}"
end
