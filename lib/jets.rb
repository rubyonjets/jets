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
require "zeitwerk"

require "jets/autoloaders"
Jets::Autoloaders.log! if ENV["JETS_AUTOLOAD_LOG"]
Jets::Autoloaders.once.setup

module Jets
  RUBY_VERSION = "2.5.3"
  class Error < StandardError; end
  extend Core # root, logger, etc
end

require "jets/core_ext/kernel"

root = File.expand_path("..", __dir__)

$:.unshift("#{root}/vendor/jets-gems/lib")
require "jets-gems"

$:.unshift("#{root}/vendor/rails/actionpack/lib")
$:.unshift("#{root}/vendor/rails/actionview/lib")
# will require action_controller, action_pack, etc later when needed

Jets::Autoloaders.once.preload("#{__dir__}/jets/db.rb") # required for booter.rb:112: setup_db
