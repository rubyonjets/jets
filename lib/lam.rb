$:.unshift(File.expand_path("../", __FILE__))
require "lam/version"
require "attr_extras"
require 'active_support/core_ext/string'

module Lam
  autoload :Util, "lam/util"
  autoload :Command, "lam/command"
  autoload :CLI, "lam/cli"
  autoload :Build, 'lam/build'
  autoload :Process, 'lam/process'
  autoload :BaseController, 'lam/base_controller'
end
