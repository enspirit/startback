require 'rspec/core/rake_task'

namespace :test do

  desc "Run RSpec unit tests"
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = "spec/unit/**/test_*.rb"
    t.rspec_opts = %{-Ilib -Ispec --color --backtrace --format progress --format RspecJunitFormatter --out spec/rspec-unit.xml}
  end

  desc "Run the tests in the examples folder"
  task :example do
    Bundler.with_original_env do
      system("cd example && bundle exec rake")
    end
  end

  task :all => [:unit, :example]
end
task :test => :'test:all'
