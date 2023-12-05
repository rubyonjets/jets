require "action_mailer"

module Jets::Internal
  # Reference: https://github.com/rails/rails/blob/master/actionmailer/lib/action_mailer/railtie.rb
  class Actionmailer < ::Jets::Turbine
    config.action_mailer = ActiveSupport::OrderedOptions.new
    config.action_mailer.show_previews = false

    initializer "action_mailer.logger" do
      ActiveSupport.on_load(:action_mailer) { self.logger ||= Jets.logger }
    end

    initializer "action_mailer.set_configs" do |app|
      options = app.config.action_mailer
      options.default_url_options ||= {}
      options.preview_path ||= "#{Jets.root}/app/previews" if options.show_previews

      ActiveSupport.on_load(:action_mailer) do
        include AbstractController::UrlFor
        extend ::JetsTurbines::RoutesHelpers.with(app.routes) # named routes helpers
        include app.routes.mounted_helpers # mounted routes helpers: main_app and blorgh

        register_interceptors(options.delete(:interceptors))
        register_preview_interceptors(options.delete(:preview_interceptors))
        register_observers(options.delete(:observers))

        if options.smtp_settings
          self.smtp_settings = options.smtp_settings
        end

        smtp_timeout = options.delete(:smtp_timeout)

        if self.smtp_settings && smtp_timeout
          self.smtp_settings[:open_timeout] ||= smtp_timeout
          self.smtp_settings[:read_timeout] ||= smtp_timeout
        end

        options.each { |k, v| send("#{k}=", v) }
      end
    end

    initializer "action_mailer.routes" do |app|
      if app.config.action_mailer.show_previews
        app.routes.append do
          get "/jets/mailers", to: "jets/mailers#index", internal: true
          get "/jets/mailers/*path", to: "jets/mailers#preview", internal: true
        end
      end
    end
  end
end
