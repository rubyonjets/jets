$:.unshift(File.expand_path("../", __FILE__))
require "lam/version"

module Lam
  autoload :Command, "lam/command"
  autoload :CLI, "lam/cli"
end
