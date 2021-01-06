class Jets::Router
  module Dsl
    include Mount

    # Methods supported by API Gateway
    %w[any delete get head options patch post put].each do |method_name|
      define_method method_name do |path, options={}|
        create_route(options.merge(path: escape_path(path), method: __method__))
      end
    end

    def namespace(ns, &block)
      scope(module: ns, prefix: ns, as: ns, from: :namespace, &block)
    end

    def prefix(prefix, &block)
      scope(prefix: prefix, &block)
    end

    # scope supports three options: module, prefix and as.
    # Jets vs Rails:
    #   module - module
    #   prefix - path
    #   as - as
    def scope(args)
      # normalizes `scope(:admin)` as `scope(prefix: :admin)`
      options = case args
      when Hash
        args
      when String, Symbol
        { prefix: args }
      end

      root_level = @scope.nil?
      @scope = root_level ? Scope.new(options) : @scope.new(options)
      yield
    ensure
      @scope = @scope.parent if @scope
    end

    # resources macro expands to all the routes
    def resources(*items, **options)
      items.each do |item|
        scope_options = scope_options!(item, options)
        scope_options[:from] = :resources # flag for MethodCreator logic: to handle method_name_leaf and more
        scope(scope_options) do
          each_resources(item, options, block_given?)
          yield if block_given?
        end
      end
    end

    def scope_options!(item, options)
      prefix = if options[:prefix]
        # prefix given from the resources macro get automatically prepended to the item name
        p = options.delete(:prefix)
        "#{p}/#{item}"
      else
        item
      end

      {
        as: options.delete(:as) || item, # delete as or it messes with create_route
        prefix: prefix,
        param: options[:param],
        # module: options.delete(:module) || item, # NOTE: resources does not automatically set module, but namespace does
      }
    end

    def each_resources(name, options={}, has_block=nil)
      o = Resources::Options.new(name, options)
      f = Resources::Filter.new(name, options)
      param = default_param(has_block, name, options)

      get name, o.build(:index) if f.yes?(:index)
      get "#{name}/new", o.build(:new) if f.yes?(:new) && !api_mode?
      get "#{name}/:#{param}", o.build(:show) if f.yes?(:show)
      post name, o.build(:create) if f.yes?(:create)
      get "#{name}/:#{param}/edit", o.build(:edit) if f.yes?(:edit) && !api_mode?
      put "#{name}/:#{param}", o.build(:update) if f.yes?(:update)
      post "#{name}/:#{param}", o.build(:update) if f.yes?(:update) # for binary uploads
      patch "#{name}/:#{param}", o.build(:update) if f.yes?(:update)
      delete "#{name}/:#{param}", o.build(:delete) if f.yes?(:delete)
    end

    def resource(*items, **options)
      items.each do |item|
        scope_options = scope_options!(item, options)
        scope_options[:from] = :resource # flag for MethodCreator logic: to handle method_name_leaf and more
        scope(scope_options) do
          each_resource(item, options, block_given?)
          yield if block_given?
        end
      end
    end

    def each_resource(name, options={}, has_block=nil)
      o = Resources::Options.new(name, options.merge(singular_resource: true))
      f = Resources::Filter.new(name, options)

      get "#{name}/new", o.build(:new) if f.yes?(:new) && !api_mode?
      get name, o.build(:show) if f.yes?(:show)
      post name, o.build(:create) if f.yes?(:create)
      get "#{name}/edit", o.build(:edit) if f.yes?(:edit) && !api_mode?
      put name, o.build(:update) if f.yes?(:update)
      post name, o.build(:update) if f.yes?(:update) # for binary uploads
      patch name, o.build(:update) if f.yes?(:update)
      delete name, o.build(:delete) if f.yes?(:delete)
    end

    def member
      @on_option = :member
      yield
      @on_option = nil
    end

    def collection
      @on_option = :collection
      yield
      @on_option = nil
    end

    # If a block has pass then we assume the resources will be nested and then prefix
    # the param name with the resource. IE: post_id instead of id
    # This avoids an API Gateway parent sibling variable collision.
    def default_param(has_block, name, options)
      default_param = has_block ? "#{name.to_s.singularize}_id".to_sym : :id
      options[:param] || default_param
    end

    # root "posts#index"
    def root(to, options={})
      default = {path: '', to: to, method: :get, root: true}
      options = default.merge(options)
      MethodCreator.new(options, @scope).create_root_helper
      @routes << Route.new(options, @scope)
    end
    private

    def escape_path(path)
      path.to_s.split('/').map { |s| s =~ /\A[:\*]/ ? s : CGI.escape(s) }.join('/')
    end
  end
end
