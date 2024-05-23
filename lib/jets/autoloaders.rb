require "jets/bundle"
Jets::Bundle.setup
require "zeitwerk"
require_relative "autoloaders/gem"
require_relative "autoloaders/main"

module Jets
  class Autoloaders
    class << self
      extend Memoist

      def main
        Main
      end
      memoize :main

      def gem
        Gem
      end
      memoize :gem
    end
  end
end
