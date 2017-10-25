$:.unshift(File.expand_path("../", __FILE__))
require "lam/version"
require "attr_extras"

module Lam
  autoload :Command, "lam/command"
  autoload :CLI, "lam/cli"
  autoload :Build, 'lam/build'
  autoload :Process, 'lam/process'
  autoload :BaseController, 'lam/base_controller'
end
