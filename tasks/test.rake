namespace :test do

  desc "Run RSpec unit tests"
  task :unit do
    system("rspec -Ilib -Ispec --pattern 'spec/unit/**/test_*.rb' --color --backtrace --fail-fast")
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
