class Jets::Router::Route
  # The Node class groups logic that requires both of route and scope info.
  # It does not really belong in either the Route or Scope class and
  # requires both to do its job.  So it gets its own class.
  # This seems to help keep the Route and Scope classes simpler.
  #
  # An instance of this class is made available with each
  # iteration of loop that processes the DSL scopes.
  class Node
    attr_reader :route, :scope, :leaf_scope
    def initialize(route, scope)
      @route, @scope = route, scope # scope is current scope of iteration
      @info = route.info
      @options = route.options
      @leaf_scope = @route.scope # the route scope is the leaf scope
    end

    def append_path?
      has_path? && add_path_segment?
    end

    def append_param?
      has_param? && add_path_segment?
    end

    def append_as?
      has_path? && add_path_segment? ||
      scope.from.nil? && scope.as
    end

    # Accounts for shallow scope. Example:
    #
    #   resources :posts, shallow: true do
    #     resources :comments do
    #       resources :likes
    #     end
    #   end
    #
    # add_path_segment? = add_path_segment_considering_shallow?
    #
    def add_path_segment?
      if param_action? && shallow_param_action?
        leaf? # only add path segments for leaf
      elsif paramless_action? && shallow_paramless_action?
        leaf? || leaf_scope.real_parent?(scope)
      else
        true # default is to always path preceding path segments
      end
    end

    def shallow_param_action?
      lookahead_shallow? || leaf_scope.any_parent_shallow?
    end

    def shallow_paramless_action?
      lookahead_shallow?(parent: true) || scope.any_parent_shallow?
    end

    def lookahead_shallow?(parent: false)
      next_scope = scope
      while next_scope
        check_scope = parent ? next_scope.parent : next_scope
        # Important to check next_scope == leaf_scope
        # Otherwise it'll collapse path segments for higher scopes also.
        return true if check_scope.shallow? && next_scope == leaf_scope
        next_scope = next_scope.next
      end
      false
    end

    def has_path?
      scope.resolved_path && !scope.virtual?
    end

    def has_param?
      return false if scope.root?

      resolved_param && param_action? ||
      scope.resource_descendent? && !leaf? ||
      scope.resource_sibling? && !leaf?
    end

    def resolved_as
      as = scope.as || scope.resource_name
      # as = scope.as || scope.resource_name
      if scope.resource_name
        controller = nil # dont need controller. can infer from resources, namespace, etc
      else # direct route method without scope or module only etc
        controller = @info.controller.split('/').last if leaf? #&& as.nil?
      end
      [as, controller].compact.join('_')
    end

    def param_action?
      @options[:on] == :member || scope.from == :member ||
      %w[edit show update destroy].include?(@info.action)
    end

    def paramless_action?
      @options[:on] == :collection || scope.from == :collection ||
      %w[index new create].include?(@info.action)
    end

    def leaf?
      scope == leaf_scope
    end

    def resolved_path
      scope.resolved_path
    end

    def resolved_param
      case scope.from
      when :resources, :member
        ":#{param}"
      else # :resource, :namespace, :path, :collection
        nil
      end
    end

    # If a block has pass then we assume the resources will be nested and then prefix
    # the param name with the resource. IE: post_id instead of id
    # This avoids an API Gateway parent sibling variable collision.
    def param
      return scope.options[:param] if scope.options[:param]

      if leaf? && Jets.config.routes.allow_sibling_conflicts
        "id"
      elsif scope.resource_descendent? ||
            scope.resource_sibling? && scope.colliding_resource_sibling?
        "#{scope.resource_name.to_s.singularize}_id"
      else
        "id"
      end
    end
  end
end
