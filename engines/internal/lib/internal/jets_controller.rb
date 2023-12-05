require_relative "turbines/helpers"
require_relative "turbines/routes_helpers"

module Jets::Internal
  class JetsController < ::Jets::Turbine
    config.cache_store = :memory_store
    config.jets_controller = ActiveSupport::OrderedOptions.new
    config.jets_controller.default_protect_from_forgery = nil
    config.jets_controller.perform_caching = false
    config.jets_controller.wrap_parameters_by_default = true
    config.jets_controller.cache_store = nil

    initializer "action_controller.set_helpers_path" do |app|
      require "action_controller/metal/helpers"
      ActionController::Helpers.helpers_path = app.helpers_paths
    end

    initializer "jets_controller.set_configs" do |app|
      paths   = app.config.paths
      options = app.config.jets_controller

      options.logger      ||= Jets.logger
      options.cache_store ||= Jets.cache

      ActiveSupport.on_load(:jets_controller) do
        wrap_parameters format: [:json] if app.config.jets_controller.wrap_parameters_by_default && respond_to?(:wrap_parameters)
      end
    end

    initializer "jets_controller.set_caching" do |app|
      ActiveSupport.on_load(:jets_controller) do
        self.perform_caching = app.config.jets_controller.perform_caching
        self.cache_store = app.config.cache_store # IE: default is :memory_store
      end
    end

    initializer "jets_controller.request_forgery_protection" do |app|
      ActiveSupport.on_load(:jets_controller) do
        default_protect_from_forgery = app.config.jets_controller.default_protect_from_forgery
        if default_protect_from_forgery.nil? && app.config.mode == "html" || default_protect_from_forgery
          protect_from_forgery with: :exception
        end
      end
    end
  end
end
