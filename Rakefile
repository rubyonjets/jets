require "bundler/setup"
Bundler.setup
require "bundler/gem_tasks"
require "rspec/core/rake_task"

task :default => :spec

RSpec::Core::RakeTask.new

require_relative "lib/jets"
desc "Generates cli reference docs as markdown"
task :docs do
  Jets::Autoloaders.once.eager_load
  Jets::Commands::Markdown::Creator.create_all
end

# Thanks: https://docs.ruby-lang.org/en/2.1.0/RDoc/Task.html
require 'rdoc/task'
require 'jets/rdoc'

RDoc::Task.new do |rdoc|
  rdoc.options += Jets::Rdoc.options
end

