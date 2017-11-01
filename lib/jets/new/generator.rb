require 'fileutils'
require 'colorize'
require 'active_support/core_ext/string'

class Jets::New
  class Generator
    def initialize(project_name, options={})
      @project_name = project_name
      @options = options
    end

    def run
      copy
      git_init
    end

    def copy
      project_root = @project_name
      source_root = File.expand_path("../../new/templates/#{@options[:template]}", __FILE__)
      puts "source_root #{source_root}".colorize(:cyan)
      paths = Dir.glob("#{source_root}/**/{*,.*}").
                select {|p| File.file?(p) }
      paths.each do |src|
        dest = src.gsub(%r{.*starter/},'')
        dest = "#{project_root}/#{dest}"
        puts "  dest #{dest}".colorize(:cyan)

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

    def git_init
      git_installed = system("type git > /dev/null")
      return unless git_installed

      system("cd #{@project_name} && git init")
      system("cd #{@project_name} && git add .")
      system("cd #{@project_name} && git commit -m 'first commit'")
    end
  end
end
