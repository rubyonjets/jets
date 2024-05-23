require "fileutils"
require "thor"

module Jets::CLI::Group
  class Base < Thor::Group
    include Thor::Actions
    include Actions
    include Helpers

    add_runtime_options! # force, pretend, quiet, skip options
  end
end
