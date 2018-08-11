require "bundler/gem_tasks"
require "rspec/core/rake_task"

task :default => :spec

RSpec::Core::RakeTask.new

require_relative "lib/jets"
desc "Generates cli reference docs as markdown"
task :docs do
  Jets::Commands::Markdown::Creator.create_all
end