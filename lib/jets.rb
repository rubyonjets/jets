$stdout.sync = true unless ENV["JETS_STDOUT_SYNC"] == "0"

$:.unshift(File.expand_path("../", __FILE__))

require "jets/core_ext/bundler"
require "jets/autoloaders"
Jets::Autoloaders.log! if ENV["JETS_AUTOLOAD_LOG"]
Jets::Autoloaders.once.setup # must be called before cli.setup
Jets::Autoloaders.cli.setup

require "active_support"
require "active_support/concern"
require "active_support/core_ext"
require "active_support/dependencies"
require "active_support/ordered_hash"
require "active_support/ordered_options"
require "cfn_camelizer"
require "cfn_status"
require "fileutils"
require "memoist"
require "rainbow/ext/string"
require "serverlessgems"

module Jets
  MAX_FUNCTION_NAME_SIZE = 64

  class Error < StandardError; end
  extend Core # root, logger, etc
end

Jets::Autoloaders.once.preload("#{__dir__}/jets/db.rb") # required for booter.rb: setup_db
