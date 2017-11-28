require 'fileutils'
require 'colorize'
require 'active_support/core_ext/string'
require 'thor'
require 'bundler'

class Jets::Commands::Sequence < Thor::Group
private
  def copy
    project_root = project_name
    source_root = File.expand_path("../../new/templates/#{@options[:template]}", __FILE__)
    paths = Dir.glob("#{source_root}/**/{*,.*}").
              select {|p| File.file?(p) }
    paths.each do |src|
      dest = src.gsub(%r{.*starter/},'')
      dest = "#{project_root}/#{dest}"

      if File.exist?(dest) and !@options[:force]
        puts "already exists: #{dest}".colorize(:yellow) unless @options[:quiet]
      else
        puts "creating: #{dest}".colorize(:green) unless @options[:quiet]
        dirname = File.dirname(dest)
        FileUtils.mkdir_p(dirname) unless File.exist?(dirname)
        FileUtils.cp(src, dest)
      end
    end
  end
end

class Jets::Commands::New < Jets::Commands::Sequence
  include Thor::Actions

  def self.source_root
    File.expand_path("new/templates/starter", File.dirname(__FILE__))
  end

  argument :project_name
  class_option :repo, default: "tongueroo/starter", desc: "Starter repo to use."

  def start_here
    puts "Creating new project called #{project_name}."
    puts "options #{options.inspect}"
    puts "args #{args.inspect}"
    puts "project_name #{project_name.inspect}"
    directory ".", project_name
  end

  def git_init
    git_installed = system("type git > /dev/null")
    return unless git_installed

    system("cd #{project_name} && git init")
    system("cd #{project_name} && git add .")
    system("cd #{project_name} && git commit -m 'first commit'")
  end

  def bundle_install
    Bundler.with_clean_env do
      system("cd #{project_name} && BUNDLE_IGNORE_CONFIG=1 bundle install")
    end
  end

  def user_message
    puts "Congrats 🎉 You have successfully created a Jets project."
    puts "To deploy the project to AWS Lambda:"
    puts "  cd #{project_name}".colorize(:green)
    puts "  jets deploy".colorize(:green)
  end
end
