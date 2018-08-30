namespace :test do

  desc "Run RSpec unit tests"
  task :unit do
    system("rspec --fail-fast=1 -Ilib -Ispec --pattern 'spec/unit/**/test_*.rb' --color --backtrace --fail-fast")
  end

  desc "Runs the webspicy functional tests"
  task :webspicy do
    require "webspicy"
    Webspicy::Tester.new(Path.dir.parent/'webspicy').call
  end

  task :all => [:unit, :webspicy]
end

task :test => [:"test:all"]
