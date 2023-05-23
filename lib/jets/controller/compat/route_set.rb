module Jets::Controller::Compat
  module RouteSet
    # Override behavior from ActionDispatch::Routing::UrlFor
    #
    # When Jets include ActionDispatch::Routing::UrlFor is in the Jets::Controller::Base class
    # It sets @_routes = nil
    #
    # We need to set @_routes to the Jets::Controller::Request routes object
    # to provide a Jets custom routes object that's compatiable the Rails routes object.
    #
    # Why does @_routes have to be set?
    #
    # How this works is a bit hard to follow. Here's the current trace with actionpack 7.0.8
    #
    # Here's where controller render goes from controller-land to view-land.
    #
    #     action_controller/metal/rendering.rb:158:in `render_to_body'
    #     action_view/rendering.rb:114:in `render_to_body'
    #
    # In action_view/rendering.rb render_to_body => _render_template is called and
    # a view_context is created.
    #
    #     def view_context
    #       view_context_class.new(lookup_context, view_assigns, self)
    #     end
    #
    # self is the <PostsController>. The controller instance is the _routes is used.
    # The view_context_class is somehow a wrapped anonymous class that has the
    # ActionView::Base#initialize method.
    #
    # Usage:
    #
    #     module Jets::Controller
    #       class Base < Jets::Lambda::Functions
    #         ...
    #         include Compat::RouteSet::ControllerPrepend
    #         ...
    #         include ActionController::UrlFor # includes ActionDispatch::Routing::UrlFor
    #         ...
    #         include Compat::RouteSet::ControllerAppend
    #
    def initialize(*)
      @_routes = self.class._routes # set by inherited hook in JetsTurbines::RoutesHelpers.with
      super
    end
  end
end
