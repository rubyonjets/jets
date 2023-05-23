# frozen_string_literal: true

require "jets/app_loader"

# If we are inside a Jets application this method performs an exec and thus
# the rest of this script is not run.
# exec_app either runs bin/jets or an inline version of it.
Jets::AppLoader.exec_app

# Allow running jets with local source code when bin/jets does not exist
# Useful for development: jets build
# Also allows jets to work without a bin/jets file in the project.
if File.exist?("config/application.rb")
  APP_PATH = File.expand_path("config/application", Dir.pwd)
  require "jets"
  require "jets/commands"
  return
end

# The rest of the script runs if outside of Jets application. IE:
# jets new demo

require "jets/ruby_version_check"
Signal.trap("INT") { puts; exit(1) }

require "jets/command"

if ARGV.first == "plugin"
  ARGV.shift
  Jets::Command.invoke :plugin, ARGV
else
  Jets::Command.invoke :application, ARGV
end
