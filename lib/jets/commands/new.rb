require 'fileutils'
require 'colorize'
require 'active_support/core_ext/string'
require 'thor'

class Jets::Commands::New < Thor::Group
  class_option :repo, default: "tongueroo/starter", desc: "Starter repo to use."

  def start_here
    puts "Creating new project called #{@project_name}."
    puts "options #{options.inspect}"
    puts "args #{args.inspect}"

    # o = Thor::Options.new({}, {}, false, true)
    # pp o.parse(args)
    puts "start_here"
  end
end

# class Jets::Commands::New
#   class Generator < Thor::Group
#     # There's got to be cleaner way of sharing these options.  Probably need to
#     # learn how to make a thor command a group.
#     def self.common_options
#       [
#         [:repo, default: "starter", desc: "Starter template to use."]
#       ]
#     end

#     common_options.each do |params|
#       class_option *params
#     end
#     # class_option :repo#, default: 'bar'
#     def call1
#       puts "options #{options.inspect}"
#       puts "args #{args.inspect}"

#       # o = Thor::Options.new({}, {}, false, true)
#       # pp o.parse(args)
#       puts "call1"
#     end
#     # def initialize(project_name, options={})
#     #   @project_name = project_name
#     #   @options = options
#     # end

#     # def run
#     #   return if @options[:noop]
#     #   copy
#     #   # bundle_install
#     #   # git_init
#     #   user_message
#     # end

#     # def copy
#     #   project_root = @project_name
#     #   source_root = File.expand_path("../../new/templates/#{@options[:template]}", __FILE__)
#     #   paths = Dir.glob("#{source_root}/**/{*,.*}").
#     #             select {|p| File.file?(p) }
#     #   paths.each do |src|
#     #     dest = src.gsub(%r{.*starter/},'')
#     #     dest = "#{project_root}/#{dest}"

#     #     if File.exist?(dest) and !@options[:force]
#     #       puts "already exists: #{dest}".colorize(:yellow) unless @options[:quiet]
#     #     else
#     #       puts "creating: #{dest}".colorize(:green) unless @options[:quiet]
#     #       dirname = File.dirname(dest)
#     #       FileUtils.mkdir_p(dirname) unless File.exist?(dirname)
#     #       FileUtils.cp(src, dest)
#     #     end
#     #   end
#     # end

#     # def bundle_install
#     #   Bundler.with_clean_env do
#     #     system("cd #{@project_name} && BUNDLE_IGNORE_CONFIG=1 bundle install")
#     #   end
#     # end

#     # def git_init
#     #   git_installed = system("type git > /dev/null")
#     #   return unless git_installed

#     #   system("cd #{@project_name} && git init")
#     #   system("cd #{@project_name} && git add .")
#     #   system("cd #{@project_name} && git commit -m 'first commit'")
#     # end

#     # def user_message
#     #   puts "Congrats 🎉 You have successfully created a Jets project."
#     #   puts "To deploy the project to AWS Lambda:"
#     #   puts "  cd #{@project_name}".colorize(:green)
#     #   puts "  jets deploy".colorize(:green)
#     # end
#   end
# end
