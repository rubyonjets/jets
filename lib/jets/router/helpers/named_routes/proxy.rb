module Jets::Router::Helpers::NamedRoutes
  class Proxy
    include AddFullUrl

    def initialize(view_context, helpers_module)
      @helpers = helpers_class(helpers_module).new(view_context)
    end

    # * The helpers_module is passed as a argument to give the anonymous class
    #   access via closure at include time.
    # * view_context is passed at initialize to provide access at instantiation time.
    def helpers_class(helpers_module)
      Class.new do
        include helpers_module # IE: Generated::MainAppHelpers
        def initialize(view_context)
          @view_context = view_context
        end

        # Important:
        #
        # * The add_full_url method needs url_options.
        #   Without url_options the proxy methods are unavailable and creates
        #   an infinite loop with method_missing.
        # * request is needed for add_apigw_stage? to check request correctly
        #   Otherwise, gems like kingsman, that use the named routes proxy methods,
        #   won't get able to get the correct url with the stage name prepended.
        #
        # The request is the main reason an anonymous class is used since the
        # view_context has included modules like ApigwStage that assume a
        # request method is available.
        delegate :url_options, :request, :event, to: :@view_context
      end
    end

    # No need to check respond_to? and call raise NoMethodError again because anonymous
    # class will already return a undefined method error.
    #
    # It's annoying that we need to add_full_url here because
    # the proxy calls the url methods with a module view_context instead
    # of the controller or view_context instance. So we don't have access to
    # the request and url_options.  The url_options are only available in the controller
    # or view_context instance.
    #
    # So we call the path method instead and then add_full_url here.
    # Not calling the url method directly because could add the full url twice,
    # when the user is setting the default_url_options.
    # Also calling the url method would cause an error because request and url_options
    # is not available.
    #
    # The logic is a bit convoluted but it works. Rails does something similar
    # with their RoutesProxy class and view_context.url_options.
    def method_missing(method_name, *args)
      path_name = method_name.to_s.sub(/_url$/, '_path').to_sym
      path = @helpers.send(path_name, *args)
      if method_name.to_s.end_with?('_url')
        options = args.extract_options!
        options.merge!(path: path)
        options = url_options.merge(options)
        add_full_url(options)
      else
        path
      end
    end
  end
end

