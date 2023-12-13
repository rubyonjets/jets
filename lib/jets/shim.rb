# frozen_string_literal: true

module Jets
  module Shim
    extend Memoist

    def handler(event, context, route = nil)
      Handler.new(event, context, route).handle
    end

    def to_rack_env(event, context)
      Handler.new(event, context).to_rack_env
    end

    def boot
      # Don't boot Jets in maintenance mode. Makes cold start much faster.
      return if Maintenance.enabled?

      paths = %w[
        config/jets/shim.rb
      ]
      paths.map! do |path|
        path.starts_with?(".") ? path : "./#{path}"
      end
      found = paths.find { |p| File.exist?(p) }
      if found
        require found # calls Jets.shim.configure
      else
        config.rack_app # all settings are inferred
      end

      # Boot Jets to add additional features
      Jets.boot
    end

    def configure
      yield config
    end

    def config
      Config.instance
    end

    extend self
  end
end
