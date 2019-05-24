module Jets
  # Reference: https://github.com/rails/rails/blob/master/actionmailer/lib/action_mailer/railtie.rb
  class Mailer < ::Jets::Turbine
    config.action_mailer = ActiveSupport::OrderedOptions.new

    initializer "action_mailer.logger" do
      ActiveSupport.on_load(:action_mailer) { self.logger ||= Jets.logger }
    end

    initializer "action_mailer.set_configs" do |app|
      options = app.config.action_mailer || ActiveSupport::OrderedOptions.new
      options.default_url_options ||= {}
      options.default_url_options[:protocol] ||= "https"
      options.show_previews = false if options.show_previews.nil?
      options.preview_path ||= "#{Jets.root}/app/previews" if options.show_previews
      options.view_paths ||= "#{Jets.root}/app/views"

      # TODO: Dont think Jets sets asset_host the same way
      # make sure readers methods get compiled
      # options.asset_host          ||= app.config.asset_host
      # options.relative_url_root   ||= app.config.relative_url_root

      ActiveSupport.on_load(:action_mailer) do
        include AbstractController::UrlFor
        # TODO: figure out rest of the helpers
        # extend ::AbstractController::Railties::RoutesHelpers.with(app.routes, false)
        # include app.routes.mounted_helpers

        register_interceptors(options.delete(:interceptors))
        register_preview_interceptors(options.delete(:preview_interceptors))
        register_observers(options.delete(:observers))

        options.each { |k, v| send("#{k}=", v) }
      end
    end

    after_initializer "action_mailer.routes" do |app|
      if app.config.action_mailer.show_previews
        app.routes.draw do
          get "jets/mailers", to: "jets/mailers#index"
          get "jets/mailers/*path", to: "jets/mailers#preview"
        end

        ActiveSupport.on_load :action_controller do
          internal_views = File.expand_path("internal/app/views", File.dirname(__FILE__))
          ActionController::Base.append_view_path(internal_views)
        end
      end
    end
  end
end
