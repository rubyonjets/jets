# frozen_string_literal: true

require "cgi"
require "rack"

module Jets
  # This module helps build the runtime properties that are displayed in
  # Jets::InfoController responses. These include the active Jets version,
  # Ruby version, Rack version, and so on.
  module Info
    mattr_accessor :properties, default: []

    class << @@properties
      def names
        map(&:first)
      end

      def value_for(property_name)
        if property = assoc(property_name)
          property.last
        end
      end
    end

    class << self # :nodoc:
      def property(name, value = nil)
        value ||= yield
        properties << [name, value] if value
      rescue Exception
      end

      def to_s
        column_width = properties.names.map(&:length).max
        info = properties.map do |name, value|
          value = value.join(", ") if value.is_a?(Array)
          "%-#{column_width}s   %s" % [name, value]
        end
        info.unshift "About your application's environment"
        info * "\n"
      end

      alias inspect to_s

      def to_html
        (+"<table>").tap do |table|
          properties.each do |(name, value)|
            table << %(<tr><td class="name">#{CGI.escapeHTML(name.to_s)}</td>)
            formatted_value = if value.kind_of?(Array)
              "<ul>" + value.map { |v| "<li>#{CGI.escapeHTML(v.to_s)}</li>" }.join + "</ul>"
            else
              CGI.escapeHTML(value.to_s)
            end
            table << %(<td class="value">#{formatted_value}</td></tr>)
          end
          table << "</table>"
        end
      end
    end

    # The Jets version.
    property "Jets version" do
      Jets.version.to_s
    end

    # The Ruby version and platform, e.g. "2.0.0-p247 (x86_64-darwin12.4.0)".
    property "Ruby version" do
      RUBY_DESCRIPTION
    end

    # The RubyGems version, if it's installed.
    property "RubyGems version" do
      Gem::VERSION
    end

    property "Rack version" do
      ::Rack.release
    end

    property "JavaScript Runtime" do
      ExecJS.runtime.name
    end

    # Note: The Jets.configuration.middleware is not available until Jets.boot finishes.
    # It's important for the jets gem not to eager load because
    # Jets.configuration.middleware is not available until after Jets.boot.
    #
    # Originally called Jets.boot here, but it results in a boot twice.
    # That results in weird behavior like commenting out DebugException middleware
    # breaks startup with ActiveSupport::Dependencies.autoload_paths freeze error.
    # The side-effect errors are hard to debug. Jets::Info should be loaded lazily.
    #
    # In Jets::Autoloaders::Gem we do_not_eager_load Jets::Info to avoid this issue.
    property "Middleware" do
      Jets.configuration.middleware.map(&:inspect)
    end

    # The application's location on the filesystem.
    property "Application root" do
      File.expand_path(Jets.root)
    end

    # The current Jets environment (development, test, or production).
    property "Environment" do
      Jets.env
    end

    # The name of the database adapter for the current environment.
    property "Database adapter" do
      ActiveRecord::Base.connection.pool.db_config.adapter
    end

    property "Database schema version" do
      ActiveRecord::Base.connection.migration_context.current_version rescue nil
    end
  end
end
