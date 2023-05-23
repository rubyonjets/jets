class Jets::Router::Route
  module AfterInitialize
    def after_initialize
      normalize_to_option!
      normalize_path_option!
      normalize_id_constraint!
      check_on_option!
    end

    # Possibly infer to option from the path. Example:
    #
    #     get 'posts/index'
    #     get 'posts', to: 'posts#index'
    #
    #     get 'posts/show'
    #     get 'posts', to: 'posts#show'
    #
    def normalize_to_option!
      return if @options[:to]

      path = @options[:path].to_s
      return unless path.include?('/')

      path = path.delete_prefix('/') # remove leading slash
      items = path.split('/')
      if items.size == 2
        @options[:to] = items.join('#')
      end
    end

    def normalize_path_option!
      path = @options[:path]
      resource_name = @scope.resource_name
      if path.is_a?(Symbol) and resource_name # Treat as controller action
        # Only supported with used within scope, resource, resources block
        action = path # IE: get :list => action = :list
        controller = @scope.virtual_controller
        # infer and set to option if not set
        @options[:to] ||= "#{controller}##{action}"
      end

      # override
      @options.merge!(path: escape_path(path)) if path
    end

    def normalize_id_constraint!
      if @options[:id] && !@options[:constraints]
        @options[:constraints] = { id: @options[:id] }
      end
    end

    def check_on_option!
      if @options[:on] && !%w[resources resource].include?(@scope.from.to_s)
        raise Jets::Router::Error.new("ERROR: The `on:` option can only be used within a resource or resources block")
      end
    end

    def escape_path(path)
      path.to_s.split('/').map { |s| s =~ /\A[:\*]/ ? s : CGI.escape(s) }.join('/')
      path = "/#{path}" unless path.starts_with?('/')
      path
    end
  end
end
