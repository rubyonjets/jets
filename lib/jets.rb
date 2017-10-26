$:.unshift(File.expand_path("../", __FILE__))
require "jets/version"

module Jets
  autoload :Command, "jets/command"
  autoload :CLI, "jets/cli"
end
