$stdout.sync = true unless ENV["JETS_STDOUT_SYNC"] == "0"
$:.unshift(File.expand_path("../", __FILE__))

require "active_support"
require "active_support/concern"
require "active_support/core_ext"
require "active_support/dependencies"
require "active_support/ordered_hash"
require "active_support/ordered_options"
require "cfn_camelizer"
require "cfn_status"
require "cli-format"
require "fileutils"
require "json"
require "memoist"
require "rainbow/ext/string"

CliFormat.default_format = "table"

require "jets/core_ext"
require "jets/autoloaders"
Jets::Autoloaders.gem.setup

module Jets
  class Error < StandardError; end
  extend Core # root, logger, etc
end
