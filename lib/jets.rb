$:.unshift(File.expand_path("../", __FILE__))
require "jets/version"
require "active_support/core_ext/string"
require "active_support/ordered_hash"
require "colorize"
require "fileutils"
require "pp" # TODO: remove pp after debugging

module Jets
  autoload :CLI, "jets/cli"
  autoload :Commands, "jets/commands"

  autoload :AwsServices, "jets/aws_services"
  autoload :Builders, 'jets/builders'
  autoload :Call, "jets/call"
  autoload :Cfn, 'jets/cfn'
  autoload :Controller, 'jets/controller'
  autoload :Erb, "jets/erb"
  autoload :Generator, "jets/generator"
  autoload :Job, 'jets/job'
  autoload :Lambda, 'jets/lambda'
  autoload :Naming, 'jets/naming'
  autoload :Processors, 'jets/processors'
  autoload :Route, "jets/route"
  autoload :Router, "jets/router"
  autoload :Server, "jets/server"

  autoload :Application, "jets/application"
  autoload :Booter, 'jets/booter'
  autoload :Core, "jets/core"
  autoload :Dotenv, 'jets/dotenv'
  autoload :Klass, 'jets/klass'
  autoload :Util, "jets/util"
  extend Core # root, logger, etc
end

# lazy loaded dependencies: depends what project. Mainly determined by Gemfile
# and config files.
if File.exist?("#{Jets.root}config/dynamodb.yml")
  $:.unshift(File.expand_path("../../vendor/dynamodb_model/lib", __FILE__))
  require "dynamodb_model"
end

# https://makandracards.com/makandra/42521-detecting-if-a-ruby-gem-is-loaded
if File.exist?("#{Jets.root}config/database.yml")
  require "active_record"
  require "pg" if Gem.loaded_specs.has_key?('pg')
end
