require_relative "turbines/asset_tag_helper"

module Jets::Internal
  class Actionview < ::Jets::Turbine
    config.action_view = ActiveSupport::OrderedOptions.new
    config.action_view.embed_authenticity_token_in_remote_forms = nil
    config.action_view.debug_missing_translation = true
    config.action_view.default_enforce_utf8 = nil
    config.action_view.image_loading = nil
    config.action_view.image_decoding = nil
    config.action_view.apply_stylesheet_media_default = true

    config.after_initialize do |app|
      ActionView::Helpers::FormTagHelper.embed_authenticity_token_in_remote_forms =
        app.config.action_view.delete(:embed_authenticity_token_in_remote_forms)
    end

    config.after_initialize do |app|
      form_with_generates_remote_forms = app.config.action_view.delete(:form_with_generates_remote_forms)
      ActionView::Helpers::FormHelper.form_with_generates_remote_forms = form_with_generates_remote_forms
    end

    config.after_initialize do |app|
      form_with_generates_ids = app.config.action_view.delete(:form_with_generates_ids)
      unless form_with_generates_ids.nil?
        ActionView::Helpers::FormHelper.form_with_generates_ids = form_with_generates_ids
      end
    end

    config.after_initialize do |app|
      default_enforce_utf8 = app.config.action_view.delete(:default_enforce_utf8)
      unless default_enforce_utf8.nil?
        ActionView::Helpers::FormTagHelper.default_enforce_utf8 = default_enforce_utf8
      end
    end

    config.after_initialize do |app|
      button_to_generates_button_tag = app.config.action_view.delete(:button_to_generates_button_tag)
      unless button_to_generates_button_tag.nil?
        ActionView::Helpers::UrlHelper.button_to_generates_button_tag = button_to_generates_button_tag
      end
    end

    config.after_initialize do |app|
      frozen_string_literal = app.config.action_view.delete(:frozen_string_literal)
      ActionView::Template.frozen_string_literal = frozen_string_literal
    end

    config.after_initialize do |app|
      ActionView::Helpers::AssetTagHelper.image_loading = app.config.action_view.delete(:image_loading)
      ActionView::Helpers::AssetTagHelper.image_decoding = app.config.action_view.delete(:image_decoding)
      ActionView::Helpers::AssetTagHelper.preload_links_header = app.config.action_view.delete(:preload_links_header)
      ActionView::Helpers::AssetTagHelper.apply_stylesheet_media_default = app.config.action_view.delete(:apply_stylesheet_media_default)
    end

    config.after_initialize do |app|
      ActiveSupport.on_load(:action_view) do
        app.config.action_view.each do |k, v|
          send "#{k}=", v
        end
      end
    end

    initializer "action_view.logger" do
      # Override log subscriber rails_root to use Jets.root
      require "action_view/log_subscriber"
      ActionView::LogSubscriber.class_eval do
        def rails_root
          @root ||= "#{Jets.root}/"
        end
      end
      ActiveSupport.on_load(:action_view) { self.logger ||= Jets.logger }
    end

    initializer "action_view.caching" do |app|
      ActiveSupport.on_load(:action_view) do
        if app.config.action_view.cache_template_loading.nil?
          ActionView::Resolver.caching = app.config.cache_classes
        end
      end
    end

    initializer "action_view.setup_action_pack" do |app|
      # Changed to :jets_controller
      ActiveSupport.on_load(:jets_controller) do
        ActionView::RoutingUrlFor.include(ActionDispatch::Routing::UrlFor)
      end
    end

    initializer "action_view.collection_caching", after: "jets_controller.set_configs" do |app|
      ActiveSupport.on_load(:action_view) do
        ActionView::PartialRenderer.collection_cache = app.config.jets_controller.cache_store
      end
    end

    config.after_initialize do |app|
      enable_caching = if app.config.action_view.cache_template_loading.nil?
        app.config.cache_classes
      else
        app.config.action_view.cache_template_loading
      end

      unless enable_caching
        app.executor.register_hook ActionView::CacheExpiry::Executor.new(watcher: app.config.file_watcher)
      end
    end

    rake_tasks do |app|
      unless app.config.api_only
        load "action_view/tasks/cache_digests.rake"
      end
    end

    # Jets additions
    initializer "action_view.event" do |app|
      ActiveSupport.on_load :action_view do
        class_eval do
          def event
            @event
          end
        end
      end
    end

    initializer "action_view.asset_tag_helper" do |app|
      ActiveSupport.on_load :action_view do
        ActionView::Helpers.send(:include, JetsTurbines::AssetTagHelper)
      end
    end

    initializer "action_view.override_debug_exceptions" do |app|
      ActiveSupport.on_load :jets_controller do
        require_relative "overrides/debug_exceptions"
      end
    end

    # Deprecated: Will remove support for webpacker in the future.
    initializer "action_view.webpacker" do |app|
      if Jets.webpacker?
        require 'webpacker'
        require 'webpacker/helper'
        ActiveSupport.on_load :action_controller do
          ActionController::Base.helper Webpacker::Helper
        end

        ActiveSupport.on_load :action_view do
          include Webpacker::Helper
        end
      end
    end
  end
end
