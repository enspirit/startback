require 'rspec/core/rake_task'

namespace :test do

  desc "Run RSpec unit tests"
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = "spec/unit/**/test_*.rb"
    t.rspec_opts = %{-Ilib -Ispec --color --backtrace --format progress --format RspecJunitFormatter --out spec/rspec-unit.xml}
  end

  desc "Runs the webspicy functional tests"
  task :webspicy do
    require "webspicy"
    res = Webspicy::Tester.new(Path.dir.parent/'webspicy').call
    abort("Webspicy tests failed") unless res == 0
  end

  task :all => [:unit, :webspicy]
end

task :test => [:"test:all"]
