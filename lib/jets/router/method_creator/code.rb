class Jets::Router::MethodCreator
  class Code
    include Jets::Router::Util

    def initialize(options, scope, controller, action=nil)
      @options, @scope, @controller, @action = options, scope, controller, action
      @path, @as = options[:path], options[:as]
    end

    def meth_args
      params = full_path.split('/').select { |x| x.include?(':') }
      items = params.map { |x| x.sub(':','') }

      items.empty? ? nil : "("+items.join(', ')+")"
    end

    def meth_result
      results = full_path.split('/').map do |x|
        if x.include?(':')
          variable = x.sub(':','')
          "\#{#{variable}.to_param}"
        else
          x
        end
      end

      '/' + results.join('/') unless results.empty?
    end

    def full_path
      route = Jets::Router::Route.new(@options, @scope)
      route.compute_path
    end

    def action
      @action || self.class.name.split('::').last.downcase # MethodCreator::Edit, MethodCreator::New, etc
    end

    def full_as
      @scope&.full_as
    end

    # The method_name_leaf is used to generate method names.
    # Can be nil because sometimes the name is fully acquired from the scope.
    def method_name_leaf
      unless %w[resource resources].include?(@scope.from.to_s) && @options[:from_scope]
        @controller
      end
    end

    def full_meth_name(suffix=nil)
      as =  @as || meth_name
      name = [as, suffix].compact.join('_')
      underscore(name)
    end

    def path_method
      return if @as == :disabled
      <<~EOL
        def #{full_meth_name(:path)}#{meth_args}
          "#{meth_result}"
        end
      EOL
    end

    def url_method
      return if @as == :disabled
      path_method_call = "#{full_meth_name(:path)}#{meth_args}"
      # Note: It is important lazily get the value of ENV['JETS_HOST'] within the method.
      # Since it is not set until the request goes through the main middleware.
      <<~EOL
        def #{full_meth_name(:url)}#{meth_args}
          "\#{ENV['JETS_HOST']}\#{#{path_method_call}}"
        end
      EOL
    end

    def param_name(name)
      # split('/').last for case:
      #
      #   resources :posts, prefix: "articles", only: :index do
      #     resources :comments, only: :new
      #   end
      #
      # Since the prefix at the scope level is added to the posts item, which results in:
      #
      #   param_name("articles/posts")
      #
      # We drop the articles prefix portion. The resources items can only be words with no /.
      #
      name.to_s.split('/').last.singularize + "_id"
    end

  private
    def singularize(s)
      s&.singularize
    end
  end
end
