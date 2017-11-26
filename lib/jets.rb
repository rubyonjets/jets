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
  autoload :Application, "jets/application"
  autoload :Util, "jets/util"
  autoload :Command, "jets/command"
  # subtasks
  autoload :Process, 'jets/process'
  autoload :Generate, 'jets/generate'
  autoload :Dynamodb, 'jets/dynamodb'
  autoload :Db, 'jets/db'

  autoload :CLI, "jets/cli"
  autoload :Build, 'jets/build'
  autoload :Cfn, 'jets/cfn'
  autoload :Deploy, 'jets/deploy'
  autoload :Delete, 'jets/delete'
  autoload :Naming, 'jets/naming'
  autoload :AwsServices, "jets/aws_services"
  autoload :New, "jets/new"
  autoload :Server, "jets/server"
  autoload :Route, "jets/route"
  autoload :Router, "jets/router"
  autoload :Console, "jets/console"
  autoload :Erb, "jets/erb"
  autoload :Call, "jets/call"

  autoload :Database, 'jets/database'

  autoload :Lambda, 'jets/lambda'
  autoload :Controller, 'jets/controller'
  autoload :Job, 'jets/job'

  autoload :Webpacker, 'jets/webpacker'
  autoload :RakeTasks, 'jets/rake_tasks'

  autoload :Dotenv, 'jets/dotenv'
  autoload :Booter, 'jets/booter'

  autoload :Klass, 'jets/klass'

  autoload :Core, "jets/core"
  extend Core # root, logger, etc

  autoload :Commands, "jets/commands"
  autoload :CommandInvoker, "jets/command_invoker"
end
