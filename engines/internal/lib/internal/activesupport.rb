require "active_support/ordered_options"

module Jets::Internal
  # Reference: https://github.com/rails/rails/blob/master/activesupport/lib/active_support/railtie.rb
  # Naming Activesupport to avoid having to use ::ActiveSupport::OrderedOptions.new
  class Activesupport < ::Jets::Turbine
    config.active_support = ActiveSupport::OrderedOptions.new
    config.active_support.disable_to_s_conversion = false

    # Currently, config.active_support.cache_format_version is used in application/bootstrap.rb

    # Note this is how Rails does it. Jets uses Jets.report_exception
    # Consider using the Rails approach. Unsure if it's worth it.
    initializer "active_support.set_error_reporter" do |app|
      ActiveSupport.error_reporter = app.executor.error_reporter
    end

    initializer "active_support.set_configs" do |app|
      app.config.active_support.each do |k, v|
        k = "#{k}="
        ActiveSupport.public_send(k, v) if ActiveSupport.respond_to? k
      end
    end

    # Sets the default value for Time.zone
    # If assigned value cannot be matched to a TimeZone, an exception will be raised.
    initializer "active_support.initialize_time_zone" do |app|
      begin
        TZInfo::DataSource.get
      rescue TZInfo::DataSourceNotFound => e
        raise e.exception "tzinfo-data is not present. Please add gem 'tzinfo-data' to your Gemfile and run bundle install"
      end
      require "active_support/core_ext/time/zones"
      Time.zone_default = Time.find_zone!(app.config.time_zone)
    end

    # Sets the default week start
    # If assigned value is not a valid day symbol (e.g. :sunday, :monday, ...), an exception will be raised.
    initializer "active_support.initialize_beginning_of_week" do |app|
      require "active_support/core_ext/date/calculations"
      beginning_of_week_default = Date.find_beginning_of_week!(app.config.beginning_of_week)

      Date.beginning_of_week_default = beginning_of_week_default
    end

  end
end
