# Looks like for zeitwerk module autovivification to work `bundle exec` must be called.
# We run Bundle.setup initially with the default so zeitwork module autovivification works
# even if the user has forgotten to call jets with `bundle exec jets`.
# This probably screws up Afterburner mode.
#
# This will not include the Jets.env group yet. Later we will call Bundle.require(:default, Jets.env)
# in Jets::Booter.require_bundle_gems
#
# Reference on what bundle exec does: https://www.justinweiss.com/articles/what-are-the-differences-between-irb/
# It essentially, does a Bundle.setup within the Ruby code.
module Jets; end
require "bundler/setup"
Bundler.setup # Same as Bundler.setup(:default)
require "zeitwerk"

module Jets
  module Autoloaders
    class OnceInflector < Zeitwerk::Inflector
      def camelize(basename, _abspath)
        map = {
          cli: "CLI",
          io: "IO",
          version: "VERSION"
        }
        map[basename.to_sym] || super
      end
    end

    class << self
      extend Memoist

      def log!
        main.log!
        once.log!
      end

      def main
        Zeitwerk::Loader.new.tap do |loader|
          loader.tag = "jets.main"
          # loader.inflector = Inflector.new # TODO: allow custom app inflector
        end
      end
      memoize :main

      def once
        Zeitwerk::Loader.new.tap do |loader|
          loader.tag = "jets.once"
          loader.inflector = OnceInflector.new

          loader.push_dir("#{__dir__}/..")
          internal_app_paths.each do |path|
            loader.push_dir("#{__dir__}/#{path}")
            # Cannot eager load internal app classes because need the app first for classes like ApplicationHelper
            loader.do_not_eager_load("#{__dir__}/#{path}")
          end

          do_not_eager_load_paths.each do |path|
            loader.do_not_eager_load("#{__dir__}/#{path}")
          end

          ignore_paths.each do |path|
            loader.ignore("#{__dir__}/#{path}")
          end
        end
      end
      memoize :once

    private
      def internal_app_paths
        %w[
          internal/app/controllers
          internal/app/helpers
          internal/app/jobs
          internal/turbines
        ]
      end

      # Do eager load but allow autoloading. Specs related files make sense here.
      def do_not_eager_load_paths
        %w[
          cli
          spec_helpers
          spec_helpers.rb
          generator
        ]
      end

      # These files will not be eager loaded and also will not follow the autoloading convention.
      # They are generally explictly required.
      def ignore_paths
        # eager loading builders/rackup_wrappers - will cause the program to exit
        %w[
          builders/rackup_wrappers
          builders/reconfigure_rails
          builders/templates
          commands/templates
          controller/middleware/webpacker_setup.rb
          core_ext
          internal
          overrides
          turbo/project
        ]
      end
    end
  end
end

