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
require "fileutils"
require "json"
require "memoist"
require "rainbow/ext/string"
require "jets-api"

require "jets/core_ext"
require "jets/autoloaders"
loader = Jets::Autoloaders.for_gem
loader.setup

module Jets
  class Error < StandardError; end
  extend Core # root, logger, etc
end

loader.eager_load if Jets.eager_load_gem?
