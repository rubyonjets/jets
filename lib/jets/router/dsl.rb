module Jets::Router
  module Dsl
    include Mount

    # Methods supported by API Gateway
    %w[any delete get head options patch post put].each do |method_name|
      define_method method_name do |*args|
        options = args.extract_options!
        normalize_path_to_controller_map_option!(args, options)
        options = options.clone
        path_arg = args.first
        if path_arg.is_a?(Symbol)
          options[:action] = path_arg # Info#action uses
        end
        options[:path] ||= path_arg
        options[:http_method] = __method__
        create_route(options)
      end
    end

    # Normally first args is a String that is the path
    #     get "/posts", to: "posts#index"
    # But it can also be a Hash that maps the path to the controller/action
    #     get "/jets/info" => "jets/info#index"
    # This logic normalize options to support both cases.
    def normalize_path_to_controller_map_option!(args, options)
      if !options[:to] && !args.first.is_a?(String) && !args.first.is_a?(Symbol)
        map = options.find { |k,v| k.is_a?(String) }
        path, to = map[0], map[1]
        options[:to] = to
        options[:path] = path
        options.delete(path)
      end
    end

    def match(path, options={})
      via = options.delete(:via) || :any
      Array(via).each do |http_method|
        http_method = :any if via == :all
        send http_method, path, options
      end
    end

    def create_route(options)
      one_apigw_method_for_all_routes_warning(options)
      route = Route.new(options, @scope)
      @routes << route
    end

    def constraints(constraints, &block)
      scope(from: :constraints, constraints: constraints, &block)
    end

    def member(&block)
      scope(from: :member, &block)
    end

    def collection(&block)
      scope(from: :collection, &block)
    end

    def defaults(data={}, &block)
      scope(from: :defaults, defaults: data, &block)
    end

    def path(path, &block)
      scope(from: :path, path: path, &block)
    end

    def namespace(ns, &block)
      scope(from: :namespace, path: ns, module: ns, as: ns, &block)
    end

    def shallow(&block)
      scope(from: :shallow, &block)
    end

    # Examples
    #   scope :admin
    #   scope path: :admin
    #   scope 'admin', as: 'admin'
    def scope(*args)
      options = args.extract_options!
      path = args.first
      options[:path] = path.to_s if path

      root_level = @scope.nil?
      @scope = root_level ? Scope.new(options) : @scope.new(options)
      yield
    ensure
      @scope = @scope.parent if @scope
    end

    # resources macro expands to all the routes
    def resources(*args)
      options = args.extract_options!
      resource_names = args
      resource_names.each do |resource_name|
        scope(options.merge(from: :resources, resource_name: resource_name)) do
          each_resource(resource_name, options)
          yield if block_given?
        end
      end
    end

    def resource(*args)
      options = args.extract_options!
      resource_names = args
      resource_names.each do |resource_name|
        scope(options.merge(from: :resource, resource_name: resource_name)) do
          each_resource(resource_name, options.merge(singular_resource: true))
          yield if block_given?
        end
      end
    end

    # Important: Options as, module, etc are handled by scope and should not be passed to the route
    HANDLED_BY_SCOPE = [:as, :module, :path, :shallow].freeze
    def each_resource(resource_name, options={})
      HANDLED_BY_SCOPE.each do |opt|
        options.delete(opt)
      end
      o = Resources::Options.new(resource_name, options)
      f = Resources::Filter.new(resource_name, options)

      # Looks a little weird with '' but the path is handled by the scope
      get '', o.build(:index) if f.yes?(:index) && !options[:singular_resource]
      post '', o.build(:create) if f.yes?(:create)
      get 'new', o.build(:new) if f.yes?(:new) && !api_mode?
      get 'edit', o.build(:edit) if f.yes?(:edit) && !api_mode?
      get '', o.build(:show) if f.yes?(:show)
      put '', o.build(:update) if f.yes?(:update)
      # post to update wont work with singular_resource because it's a route collision
      # Also makes it so that route.to is always changed
      # Leaving in case need it for some reason. Will remove later.
      # post '', o.build(:update) if f.yes?(:update) # for binary uploads
      patch '', o.build(:update) if f.yes?(:update)
      delete '', o.build(:destroy) if f.yes?(:destroy)
    end

    # root "posts#index"
    # root to: "posts#index"
    def root(*args)
      if args.size == 1
        options = args.first
        if options.is_a?(String) # root "posts#index"
          to = options
          options = {}
        elsif options.is_a?(Hash) # root to: "posts#index"
          to = options.delete(:to)
        end
      else
        to = args[0]
        options = args[1] || {}
      end

      http_method = options.delete(:via)
      http_method ||= Jets.config.api.cors ? :any : :get
      default = {path: '/', to: to, http_method: http_method, root: true}
      options = default.merge(options)
      create_route(options)
    end
  end
end
