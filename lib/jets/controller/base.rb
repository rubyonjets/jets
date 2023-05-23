require "action_controller"
require "action_controller/log_subscriber"
require "active_support/concern"
require "active_support/callbacks"
require "abstract_controller/callbacks"
require "json"
require "rack/utils" # Rack::Utils.parse_nested_query

# Controller public methods get turned into Lambda functions.
module Jets::Controller
  DEFAULT_CONTENT_TYPE = "text/html; charset=utf-8"

  class RoutingError < StandardError; end

  class Base < Jets::Lambda::Functions
    # Make Jets controller "compatible" with Rails
    # Note: Rolling include into a single Compat module causes naming conflicts with ActionController and AbstractController.
    # So we include each module individually. It's clearer this way anyway.
    include Compat::AbstractController::Base
    include Compat::ActionController::Metal
    include Compat::RouteSet
    include Compat::Caching
    include Compat::Future

    # Order matters due to use of super and the module included chain.
    include AbstractController::Rendering    # at top to normalize render options asap
    include AbstractController::Translation
    include AbstractController::AssetPaths

    include ActionController::Helpers
    include Jets::Router::Helpers::NamedRoutes

    include ActionController::UrlFor      # includes ActionDispatch::Routing::UrlFor
    include ActionController::Redirecting
    include ActionView::Layouts           # includes ActionView::Rendering
    include ActionController::Rendering
    include ActionController::Renderers::All # for use_renderers :json, :js, :xml
    include ActionController::ConditionalGet
    include ActionController::EtagWithTemplateDigest
    include ActionController::EtagWithFlash
    include ActionController::Caching
    include ActionController::MimeResponds
    include ActionController::ImplicitRender # includes BasicImplicitRender action_controller/metal/basic_implicit_render.rb
    include ActionController::StrongParameters
    include ActionController::ParameterEncoding
    include ActionController::Cookies
    include ActionController::Flash
    include ActionController::FormBuilder
    include ActionController::RequestForgeryProtection
    include ActionController::ContentSecurityPolicy
    include ActionController::PermissionsPolicy
    # include ActionController::Streaming       # not supported
    # include ActionController::DataStreaming   # not supported
    include ActionController::HttpAuthentication::Basic::ControllerMethods
    include ActionController::HttpAuthentication::Digest::ControllerMethods
    include ActionController::HttpAuthentication::Token::ControllerMethods
    # include ActionController::DefaultHeaders  # not needed
    include ActionController::Logging           # log_at: ability to change log level

    # More Jets overrides and customizations
    include Handler               # Lambda Handler process! method. Runs on AWS only.
    include RackAdapter::Action   # action rack method

    # Before callbacks should also be executed as early as possible, so
    # also include them at the bottom.
    include AbstractController::Callbacks

    # Must near bottom because decorating Rails behavior
    include Decorate::Authorization         # APIGW Authorizers
    include Decorate::UrlFor                # add_apigw_stage
    include Decorate::Redirecting           # add_apigw_stage
    include Decorate::Logging

    # Append rescue at the bottom to wrap as much as possible.
    include ActionController::Rescue

    # Add instrumentations hooks at the bottom, to ensure they instrument
    # all the methods properly.
    include ActionController::Instrumentation # TODO: figure why notifications dont work

    # Params wrapper should come before instrumentation so they are
    # properly showed in logs
    include ActionController::ParamsWrapper

    def initialize(event, context, meth, rack_env)
      # Passing in rack env so the same rack env (same object id) is used.
      # This is important for:
      #  1. Constraints lambda procs
      #  2. Controller.action rack methods
      @event = event
      @context = context
      @meth = meth
      @rack_env = rack_env
      @_request = Jets::Controller::Request.new(event: event, rack_env: @rack_env)
      # Note: Rails sets request.route in the Rails::Engine#build_request instead.
      # The Jets request class is built slightly differently, so set it here.
      # The request.routes method is need to that url_helpers work in generally.
      # It's just how Rails ActionView implements url_helpers.
      @_request.routes = self.class._routes
      @_response = Jets::Controller::Response.new
      @_response.request = @request
      # Jets::Controller::Base#initialize interface is different than ActionController::Controller::Base.
      # The super call goes to ActionController modules that can decorate and call super again.
      # At the end of the module chain is Jets::Controller::Compat::ActionController::Metal#initialize
      # which goes back to the original Jets::Lambda::Functions#initialize(event, context, meth) interface.
      super() # ActionController::Base#initialize() interface
    end

    abstract!

    use_renderers :json, :js, :xml
  end

  # See Jets::Controller::Compat::ActionController::Metal dispatch! method

  ActiveSupport.run_load_hooks(:jets_controller, Base)
end
