require "rake/testtask"

Rake::TestTask.new do |t|
  t.pattern = "test/*_test.rb"
end

desc "Run tests"
task :default => :test

desc "Build gem"
task :build do |t|
  `rm *.gem; gem build *.gemspec`
end

desc "Release gem"
task :release => :build do |t|
  `gem push *.gem`
end
