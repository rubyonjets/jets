$:.unshift(File.expand_path("../", __FILE__))
require "active_support"
require "active_support/concern"
require "active_support/core_ext"
require "active_support/dependencies"
require "active_support/ordered_hash"
require "active_support/ordered_options"
require "fileutils"
require "memoist"
require "rainbow/ext/string"
require "jets/gems"

require "jets/autoloaders"
Jets::Autoloaders.log! if ENV["JETS_AUTOLOAD_LOG"]
Jets::Autoloaders.once.setup

module Jets
  RUBY_VERSION = "2.5.3"
  MAX_FUNCTION_NAME_SIZE = 64

  class Error < StandardError; end
  extend Core # root, logger, etc
end

Jets::Autoloaders.once.preload("#{__dir__}/jets/db.rb") # required for booter.rb: setup_db
