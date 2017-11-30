$:.unshift(File.expand_path("../", __FILE__))
require "jets/version"
require "active_support/core_ext/string"
require "active_support/ordered_hash"
require "colorize"
require "fileutils"

# TODO: only load the database adapters that the app uses
$:.unshift(File.expand_path("../../vendor/dynamodb_model/lib", __FILE__))
require "dynamodb_model"
require "active_record"
require "pg"

require "pp" # TODO: remove pp

module Jets
  autoload :CLI, "jets/cli"
  autoload :Commands, "jets/commands"

  autoload :AwsServices, "jets/aws_services"
  autoload :Builders, 'jets/builders'
  autoload :Call, "jets/call"
  autoload :Cfn, 'jets/cfn'
  autoload :Controller, 'jets/controller'
  autoload :Erb, "jets/erb"
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
  autoload :WelcomeController, "jets/welcome_controller"
  extend Core # root, logger, etc
end
