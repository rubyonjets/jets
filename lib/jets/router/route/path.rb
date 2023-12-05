class Jets::Router::Route
  module Path
    # Note: The @options[:path] is missing prefix and is not support via direct create_route.
    # This is because it can be added directly to the path. IE:
    #
    #     get "myprefix/posts", to: "posts#index"
    #
    # Also, this helps to keep the method creator logic simpler.
    #
    def path(format=:jets)
      segments = path_prefixes + [path_option]
      segments = add_path_suffix(segments)
      path = segments.reject(&:blank?).join('/')
      format_path(format, path)
    end

    # When scope used directly. IE: not coming from namespace or resources
    # When coming from namespace or resources, the path is already accounted for.
    def path_prefixes
      list = []
      @scope.from_top.each do |scope|
        node = Node.new(self, scope)
        # Update @path_names as we walk down
        @path_names.merge!(scope.options[:path_names] || {})

        list << scope.resolved_path if node.append_path?
        list << node.resolved_param if node.append_param?
      end
      list.reject!(&:blank?) # allows for path: '' to remove resource name from path
      list
    end

    def path_option
      node = Node.new(self, @scope)
      path = @options[:path].to_s.delete_prefix('/') # IE: new or edit
      path.sub!(@scope.param_placeholder, ":#{node.resolved_param}")
      path
    end

    # Accounts for path names options map. Example:
    #
    #   {path_names: {new: "sign_up", edit: "edit"}}
    #
    # new    posts/new      => posts/sign_up
    # edit   posts/:id/edit => posts/:id/edit
    #
    def add_path_suffix(all_segments)
      # rip apart last path as segments
      # work with and modify segments to be returned
      segments = all_segments.last.to_s.split('/')
      current_suffix = segments.last

      new_or_edit = %w[new edit].include?(current_suffix)
      additional_action = @options[:on].is_a?(Symbol) && @options[:on] != :member && @options[:on] != :collection
      will_replace = new_or_edit || additional_action

      if will_replace
        segments_without_last = all_segments[0..-2]
        # reassemble path with additional on action
        segments_without_last << @options[:on].to_s if additional_action
        # reassemble with new suffix from path_names map
        new_suffix = @path_names[current_suffix.to_sym] || current_suffix
        segments_without_last << new_suffix
        new_last = segments_without_last.join('/')
        segments[-1] = new_last # replace
        segments
      else
        all_segments # original
      end
    end

    def path_suffixes
      list = []
      list << action_suffix if action_suffix
      list
    end

    # IE: standard: posts/:id/edit
    #     api_gateway: posts/{id}/edit
    def format_path(format, path)
      path = case format
      when :api_gateway
        api_gateway_format(path)
      when :raw
        path
      else # jets format
        ensure_jets_format(path)
      end
      path = "/#{path}" unless path.starts_with?('/') # ensure starts with / be forgiving if / accidentally not included
      path
    end
  end
end
