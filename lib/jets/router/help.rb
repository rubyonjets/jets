require 'cli-format'

module Jets::Router
  class Help
    extend Memoist

    def initialize(options={})
      @options = options
      @engines = {}
    end

    def all_routes
      Jets::Router.routes
    end

    def routes
      routes = filter(all_routes)
      collect_engine_routes(routes)
      if ENV['JETS_ROUTES_INTERNAL']
        routes = routes.select { |route| route.internal }
      else
        routes = routes.reject { |route| route.internal }
      end
      routes
    end

    def collect_engine_routes(routes)
      routes.each do |route|
        collect_engine_routes_per(route) if route.engine?
      end
    end

    def collect_engine_routes_per(route)
      name = route.endpoint
      return unless route.engine?
      return if @engines[name]

      route_set = route.rack_app.route_set
      if route_set.is_a?(Jets::Router::RouteSet)
        @engines[name] = route_set.routes
      end
    end

    def filter(routes)
      if @options[:controller]
        routes.select do |route|
          route.controller.include?(@options[:controller])
        end
      elsif @options[:grep]
        grep_pattern = Regexp.new(@options[:grep], 'i')
        proc = filter_proc(grep_pattern)
        routes.select(&proc)
      elsif @options[:reject]
        reject_pattern = Regexp.new(@options[:reject], 'i')
        proc = filter_proc(reject_pattern)
        routes.reject(&proc)
      else
        routes
      end
    end

    def filter_proc(pattern)
      Proc.new do |route|
        route.as =~ pattern ||
        route.http_method =~ pattern ||
        route.path =~ pattern ||
        route.controller =~ pattern ||
        route.mount_class_name =~ pattern
      end
    end

    def header
      header = ["As (Prefix)", "Verb", "Path (URI Pattern)", "Controller#action"]
      # any_mount = routes.any?(&:mount_class_name)
      # header << "Mount" if any_mount
      header
    end

    def any_mount?
      routes.any?(&:mount_class_name)
    end

    def print
      puts text
    end

    def text
      text = presenter_text("Routes for app:", routes)
      @engines.each do |name, routes|
        text += presenter_text("Routes for #{name}:", routes)
      end
      text
    end

    def presenter_text(summary_line, routes)
      text = format_with_newlines(summary_line)
      if routes.empty?
        text += "The routes table is empty.\n"
        return text
      end

      presenter = CliFormat::Presenter.new(@options)
      presenter.header = header unless @options[:header] == false
      routes.each do |route|
        row = [route.as, route.http_method, route.path, route.to]
        # row << route.mount_class_name if any_mount?
        presenter.rows << row
      end
      text += presenter.text.to_s # <Text::Table> => String
      text += "\n" unless text.ends_with?("\n")
      text += "\n" if @options[:format] == "space" # add another newline for space format
      text
    end

    def format_with_newlines(line)
      return '' if @options[:header] == false

      case @options[:format]
      when "markdown"
        # need leading newline for routes_table jets prints when route not found
        # Unsure why it needs to be here and not at the routes_table method.
        "\n#{line}\n\n"
      when "space"
        "#{line}\n\n"
      else
        "#{line}\n"
      end
    end
  end
end
