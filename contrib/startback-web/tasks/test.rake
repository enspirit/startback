require 'rspec/core/rake_task'

namespace :test do

  desc "Run RSpec unit tests"
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = "spec/unit/**/test_*.rb"
    t.rspec_opts = %{-Ilib -Ispec --color --backtrace --format progress --format RspecJunitFormatter --out spec/rspec-unit.xml}
  end

  task :all => [:unit]
end
task :test => :'test:all'
