require 'fileutils'
require 'colorize'
require 'active_support/core_ext/string'
require 'thor'
require 'bundler'

class Jets::Commands::Sequence < Thor::Group
  include Thor::Actions

  def self.source_root
    File.expand_path("new/templates/starter", File.dirname(__FILE__))
  end
end

# Hack to make copy_file always call template
Thor::Actions.class_eval do
  def copy_file(source, *args, &block)
    template(source, *args, &block)
  end
end
