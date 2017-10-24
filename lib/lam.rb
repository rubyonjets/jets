$:.unshift(File.expand_path("../", __FILE__))
require "lam/version"

module Lam
  autoload :Command, "lam/command"
  autoload :CLI, "lam/cli"
  autoload :Process, 'lam/process'
  autoload :BaseController, 'lam/base_controller'
end
