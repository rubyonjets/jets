require "action_dispatch"
require "action_dispatch/routing/route_set"

module Jets::Router::Compat
  # Related:
  #
  #   Jets::Controller::Compat::ActionDispatch::Routing::UrlFor
  #   Jets::Controller::Request::Compat::RouteSet
  #   Jets::Router::Compat::RouteSet
  #
  # Compat::RouteSet makes the Jets::Router::RouteSet "compatible" with the Rails RouteSet.
  # Importantly, it provides a custom url_for method that mimics the Rails url_for method.
  #
  module RouteSet
    # Original:
    # RESERVED_OPTIONS = [:host, :protocol, :port, :subdomain, :domain, :tld_length,
    #   :trailing_slash, :anchor, :params, :only_path, :script_name,
    #   :original_script_name, :relative_url_root]
    # UNKNOWN = ->(options) { ActionDispatch::Http::URL.url_for(options) }
    RESERVED_OPTIONS = ActionDispatch::Routing::RouteSet::RESERVED_OPTIONS
    UNKNOWN = ActionDispatch::Routing::RouteSet::UNKNOWN

    # This method is a version of the Rails RouteSet#url_for method.
    # It only resolves simple routes for simple cases:
    #
    #   when nil
    #   when Hash, ActionController::Parameters
    #
    # This is because ActionDispatch::Routing::UrlFor#url_for gets called before
    # and then calls out to this method. Only have to account for 2 cases to
    # mimic Jets behavior.
    #
    # Based on Jets ActionDispatch::Routing::RouteSet#url_for
    def url_for(options, route_name = nil, url_strategy = UNKNOWN, method_name = nil, reserved = RESERVED_OPTIONS)
      user = password = nil

      if options[:user] && options[:password]
        user     = options.delete :user
        password = options.delete :password
      end

      # save recall_controller for url_options when controller not specified by user
      # IE: redirect_to action: :routes
      recall_controller = options[:_recall][:controller]
      recall = options.delete(:_recall) { {} }

      original_script_name = options.delete(:original_script_name)
      # script_name = find_script_name options (original)
      script_name = options.delete(:script_name)

      if original_script_name
        script_name = original_script_name + script_name
      end

      path_options = options.dup
      reserved.each { |ro| path_options.delete ro }
      path_options[:controller] ||= recall_controller

      route_with_params = generate(route_name, path_options, recall)
      path = route_with_params.path(method_name)

      if options[:trailing_slash] && !options[:format] && !path.end_with?("/")
        path += "/"
      end

      params = route_with_params.params

      if options.key? :params
        if options[:params]&.respond_to?(:to_hash)
          params.merge! options[:params]
        else
          params[:params] = options[:params]
        end
      end

      options[:path]        = path
      options[:script_name] = script_name
      options[:params]      = params
      options[:user]        = user
      options[:password]    = password

      url_strategy.call options
    end

    def generate(route_name, options, recall = {}, method_name = nil)
      Generator.new(route_name, options, recall, self).generate
    end
    private :generate

    # This is only used for Custom resolve polymporphic path support
    # Stub out. Jets does not currently support this.
    # interface method
    def polymorphic_mappings
      {}
    end

    # ActionView::Rendering ClassMethods build_view_context_class includes these modues. Something like this:
    #
    #   def build_view_context_class(klass, supports_path, routes, helpers)
    #     ...
    #     if routes
    #       include routes.url_helpers(supports_path)
    #       include routes.mounted_helpers
    #     end
    #
    # interface method
    # def url_helpers(supports_path=true)
    #   ActionDispatch::Routing::UrlFor
    # end

    # interface method
    def mounted_helpers
      Module.new
    end

    # Based on Rails ActionDispatch::Routing::RouteSet::Generator
    class Generator
      attr_reader :options, :recall, :set, :named_route

      def initialize(named_route, options, recall, set)
        @named_route = named_route
        @options     = options.dup
        # Fix kaminari pagination links. Looks like Rails can handle nil params
        @options.delete_if { |_, v| v.to_param.nil? }
        @recall      = recall
        @set         = set
      end

      # Generates a path from routes, returns a RouteWithParams or MissingRoute.
      # MissingRoute will raise ActionController::UrlGenerationError.
      def generate
        RouteWithParams.new(named_route, recall, options)
      end
    end

    class RouteWithParams
      def initialize(route, parameterized_parts, params)
        @route = route
        @parameterized_parts = parameterized_parts
        @params = params
      end

      def params
        params = @params.dup
        # So controller and action do not show up in the query string
        params.delete(:controller)
        params.delete(:action)
        params
      end

      def path(_)
        # Match with Jets router instead of Rails router
        matcher = Jets::Router::Matcher.new
        route = matcher.find_by_controller_action(@parameterized_parts[:controller], @parameterized_parts[:action])
        if route
          path = replace_placeholders(route.path, @parameterized_parts)
          path.starts_with?('/') ? path : "/#{path}"
        else
          # Mimic Rails MissingRoute error
          constraints = @params
          missing_keys = []
          unmatched_keys = []
          routes = Jets.application.routes
          name = nil
          ActionDispatch::Journey::Formatter::MissingRoute.new(constraints, missing_keys, unmatched_keys, routes, name).path(name)
        end
      end

      def replace_placeholders(path, params)
        params.each do |key, value|
          path = path.gsub(":#{key}", value.to_param)
        end
        path
      end
    end
  end
end
