require "jets/bundle"
Jets::Bundle.setup
require "zeitwerk"

module Jets
  module Commands ; end

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
        cli.log!
      end

      def main
        Zeitwerk::Loader.new.tap do |loader|
          loader.tag = "jets.main"
          # loader.inflector = Inflector.new # TODO: allow custom app inflector
          # The main loader is configured later on in Jets::Application#setup_autoload_paths
          # because it needs access to Jets.root and Jets.config settings
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

      def cli
        Zeitwerk::Loader.new.tap do |loader|
          loader.tag = "jets.cli"
          loader.inflector = OnceInflector.new

          loader.push_dir("#{__dir__}/commands", namespace: Jets::Commands)
          loader.ignore("#{__dir__}/commands/templates*")
        end
      end
      memoize :cli

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
          commands
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

