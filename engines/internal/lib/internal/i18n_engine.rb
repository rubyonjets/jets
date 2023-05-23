module Jets::Internal
  # Reference: https://github.com/rails/rails/blob/master/activesupport/lib/active_support/i18n_railtie.rb
  class I18nEngine < ::Jets::Turbine
    config.i18n = ActiveSupport::OrderedOptions.new
    config.i18n.turbines_load_path = []
    config.i18n.load_path = []
    config.i18n.fallbacks = ActiveSupport::OrderedOptions.new

    # Set the i18n configuration after initialization since a lot of
    # configuration is still usually done in application initializers.
    config.after_initialize do |app|
      I18n.load_path |= app.config.i18n.turbines_load_path.flat_map(&:existent)
      I18n.load_path |= app.config.i18n.load_path.flat_map(&:existent)
      I18n.load_path |= Dir["#{app.root}/config/locales/*.yml"]
      I18n.load_path.uniq!
      I18n.backend.load_translations
    end
  end
end
