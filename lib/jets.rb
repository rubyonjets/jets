$:.unshift(File.expand_path("../", __FILE__))
require "jets/version"
require "active_support/core_ext/string"
require "colorize"
require "fileutils"
require "pp"
require "byebug"

module Jets
  autoload :Root, "jets/root"
  autoload :Command, "jets/command"
  # sub commands
  autoload :Process, 'jets/process'
  autoload :Generate, 'jets/generate'

  autoload :CLI, "jets/cli"
  autoload :Build, 'jets/build'
  autoload :BaseLambdaFunction, 'jets/base_lambda_function'
  autoload :BaseController, 'jets/base_controller'
  autoload :BaseJob, 'jets/base_job'
  autoload :BaseModel, 'jets/base_model'
  autoload :Config, 'jets/config'
  autoload :Cfn, 'jets/cfn'
  autoload :Deploy, 'jets/deploy'
  autoload :Delete, 'jets/delete'
  autoload :Naming, 'jets/naming'
  autoload :AwsServices, "jets/aws_services"
  autoload :New, "jets/new"

  extend Root
end
