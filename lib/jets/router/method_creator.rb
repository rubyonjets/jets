class Jets::Router
  class MethodCreator
    include Util

    def initialize(options, scope)
      @options, @scope = options, scope
      @controller, @action = get_controller_action(@options)
    end

    def define_url_helper!
      return unless @options[:method] == :get

      if %w[index new show edit].include?(@action)
        create_method(@action)
      else
        create_method("generic")
      end
    end

    # Examples:
    #
    #   posts_path: path: 'posts'
    #   admin_posts_path: prefix: 'admin', path: 'posts'
    #   new_post_path
    #
    def create_method(action)
      # Code eventually does this:
      #
      #     code = Jets::Router::MethodCreator::Edit.new
      #     def_meth code.path_method
      #
      class_name = "Jets::Router::MethodCreator::#{action.camelize}"
      klass = class_name.constantize # Index, Show, Edit, New
      code = klass.new(@options, @scope, @controller)

      def_meth(code.path_method) if code.path_method
      def_meth(code.url_method) if code.url_method
    end

    def create_root_helper
      code = Jets::Router::MethodCreator::Root.new(@options, @scope, @controller)
      def_meth(code.path_method)
      def_meth(code.url_method)
    end

    def def_meth(str)
      Jets::Router::Helpers::NamedRoutesHelper.class_eval(str)
    end
  end
end
