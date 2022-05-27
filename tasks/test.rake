require 'rspec/core/rake_task'
require 'path'

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
      abort("Example tests failed") unless $?.exitstatus == 0
    end
  end

  contribs = (Path.dir.parent/"contrib").glob("*").map do |sub|
    next unless sub.directory?
    name = sub.basename.to_sym

    desc "Run tests for #{sub}"
    task name do
      Bundler.with_original_env do
        system("cd #{sub} && bundle exec rake")
        abort("#{sub} tests failed") unless $?.exitstatus == 0
      end
    end

    name
  end

  task :all => [:unit, :example] + contribs
end
task :test => :'test:all'
