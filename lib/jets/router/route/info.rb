class Jets::Router::Route
  # Organize to.controller and to.action into a class
  # so don't have to keep repeating the logic.
  class Info
    def initialize(options, scope)
      @options, @scope = options, scope
    end

    # IE: posts
    def controller
      return if @options[:engine] # IE: { engine: Blorgh::Engine, path: "/blog" }

      controller = if @options[:controller]
          @options[:controller]
        elsif @options[:to]
          @options[:to].split('#').first # IE: posts#index => posts
        elsif @scope.virtual_controller
          @scope.virtual_controller
        else # {"/jets/info/properties"=>"jets/info#properties"}
          map = @options.find { |k,v| k.is_a?(String) }
          path, to = map[0], map[1]
          to.split('#').first
        end

      if controller.starts_with?('/')
        # absolute controller path specified. use without scope adjustments
        return controller.delete_prefix('/') # remove leading slash
      end

      # no controller found yet, imply from the scope
      segments = scoped_module_segments
      segments << controller if controller
      segments.compact.join('/') # add module
    end

    # IE: index
    def action
      if @options.key?(:action)
        @options[:action].to_s
      elsif is_collection?(@scope) || is_member?(@scope)
        @options[:path].to_s.delete_prefix('/') # action
      elsif @options[:on] && @options[:on] != :member && @options[:on] != :collection
        @options[:on].to_s
      elsif @options[:to]
        @options[:to].split('#').last
      else # {"/"=>"jets/welcome#index", :internal=>true}
        map = @options.find { |k,v| k.is_a?(String) }
        path, to = map[0], map[1]
        to.split('#').last
      end
    end

    def scoped_module_segments
      segments = []
      @scope.from_top.each do |scope|
        segments << scope.module if scope.module
        if @scope == scope # last scope node
          last_segment = @options[:module]
          segments << last_segment if last_segment
        end
      end
      segments
    end

    def is_collection?(scope)
      scope.from == :collection || @options[:on] == :collection
    end

    def is_member?(scope)
      scope.from == :member || @options[:on] == :member
    end
  end
end

