require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :test

task :test => [:rubocop, :spec]

task :rubocop do
  sh 'rubocop -P'
end
