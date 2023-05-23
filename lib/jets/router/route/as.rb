class Jets::Router::Route
  module As
    def as
      return nil if @options[:as] == :disabled
      return @options[:engine].engine_name if @options[:engine]
      return unless @options[:root] || [:get, :post, :patch, :put, :delete].include?(@options[:http_method])

      as = scoped_as
      as = add_underscore_path(as)
      as = add_action(as)
      as = add_root(as)
      as
    end

    def scoped_as
      list = []
      @scope.from_top.each do |scope|
        node = Node.new(self, scope)

        as = node.resolved_as
        as = as.to_s.singularize if node.has_param?
        list << as if as && node.append_as?
      end
      list.reject!(&:blank?) # IE: list [:posts, :comments]
      list.unshift(@options[:as]) if @options[:as]
      list.join('_').gsub('/','_') unless list.empty?
    end

    # IE: posts/:id/edit => posts
    # Using this convention so that regular routes under namespace and path
    # can be reassemble as if they were under resources
    def add_underscore_path(as)
      if as.nil? && @scope.needs_controller_path? # only consider leaf scope
        @options[:as] || underscore_path_before_param
      else
        as
      end
    end

    # IE: posts/:id/edit => posts
    # Using this convention so that regular routes under namespace and path
    # can be reassemble as if they were under resources
    def underscore_path_before_param
      action_suffixes = %w[new edit] # edit in case of singular resource
      parts = []
      path = @options[:path].to_s
      return nil if path.include?('*') || !path.ascii_only? # IE: get '*catchall', to: 'public_files#show'

      path = path.delete_prefix('/')
      path.split('/').each do |part|
        if part.starts_with?(':') || part.starts_with?('*') || action_suffixes.include?(part)
          break
        end
        parts << part
      end
      parts.map! { |p| p.gsub(/[^a-zA-Z0-9]/,'_') }
      path = parts.join('_').squeeze('_')
      if action_suffixes.include?(@info.action)
        path.singularize
      else
        path
      end
    end

    def add_action(resource)
      resource = resource.to_s
      return resource if resource.blank?

      as_name = @options[:as] || @info.action
      as_name = as_name.to_s.delete_prefix('/') if as_name

      if %w[new edit].include?(@info.action) && @options[:as].nil?
        "#{as_name}_#{resource.singularize}"  # IE: new_post
      elsif %[index create].include?(@info.action)
        resource                              # IE: posts
      elsif %w[show edit update destroy].include?(as_name)
        "#{resource.singularize}"             # IE: post
      elsif is_collection?(@scope) && @options[:as].nil?
        "#{as_name}_#{resource}"              # IE: list_post
      elsif (is_member?(@scope) || @scope.from == :resource) && @options[:as].nil?
        "#{as_name}_#{resource.singularize}"  # IE: rate_post
      elsif @scope.resource_name && @options[:as].nil?
        "#{resource.singularize}_#{as_name}"  # IE: post_list
      else
        resource                              # IE: post
      end
    end

    def add_root(as)
      @options[:root] ? 'root' : as
    end
  end
end
