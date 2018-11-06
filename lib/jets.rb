$:.unshift(File.expand_path("../", __FILE__))
require "jets/version"
require "jets/camelizer"
require "active_support"
require "active_support/core_ext"
require "active_support/dependencies"
require "active_support/ordered_hash"
require "active_support/ordered_options"
require "active_support/concern"
require "colorize"
require "fileutils"
require "memoist"

module Jets
  # When we update Jets::RUBY_VERSION, need to update jets-gems/base.rb: def jets_ruby_version also
  RUBY_VERSION = "2.5.0"

  autoload :Application, "jets/application"
  autoload :AwsInfo, "jets/aws_info"
  autoload :AwsServices, "jets/aws_services"
  autoload :Booter, 'jets/booter'
  autoload :Builders, 'jets/builders'
  autoload :Call, "jets/call"
  autoload :Cfn, 'jets/cfn'
  autoload :CLI, "jets/cli"
  autoload :Commands, "jets/commands"
  autoload :Controller, 'jets/controller'
  autoload :Core, "jets/core"
  autoload :Db, 'jets/db'
  autoload :Dotenv, 'jets/dotenv'
  autoload :Erb, "jets/erb"
  autoload :Generator, "jets/generator"
  autoload :Inflections, "jets/inflections"
  autoload :IO, "jets/io"
  autoload :Job, 'jets/job'
  autoload :Klass, 'jets/klass'
  autoload :Lambda, 'jets/lambda'
  autoload :Logger, "jets/logger"
  autoload :Mega, "jets/mega"
  autoload :Middleware, "jets/middleware"
  autoload :Naming, 'jets/naming'
  autoload :PolyFun, 'jets/poly_fun'
  autoload :Preheat, "jets/preheat"
  autoload :Processors, 'jets/processors'
  autoload :Rdoc, "jets/rdoc"
  autoload :Resource, "jets/resource"
  autoload :Route, "jets/route"
  autoload :Router, "jets/router"
  autoload :RubyServer, "jets/ruby_server"
  autoload :Rule, 'jets/rule'
  autoload :Server, "jets/server"
  autoload :Stack, "jets/stack"
  autoload :Turbine, 'jets/turbine'
  autoload :Util, "jets/util"

  extend Core # root, logger, etc
end

require "jets/core_ext/kernel"

$:.unshift(File.expand_path("../../vendor/jets-gems/lib", __FILE__))
require "jets-gems"

# lazy loaded dependencies: depends what project. Mainly determined by Gemfile
# and config files.
if File.exist?("#{Jets.root}config/dynamodb.yml")
  $:.unshift(File.expand_path("../../vendor/dynomite/lib", __FILE__))
  require "dynomite"
end

Jets::Db # trigger autoload