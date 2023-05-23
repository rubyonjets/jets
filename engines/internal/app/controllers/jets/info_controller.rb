# frozen_string_literal: true

class Jets::InfoController < Jets::ApplicationController # :nodoc:
  prepend_view_path ActionDispatch::DebugView::RESCUES_TEMPLATE_PATH
  layout -> { request.xhr? ? false : "application" }

  before_action :require_local!

  def index
    redirect_to action: :routes
  end

  def properties
    @info = Jets::Info.to_html
    @page_title = "Properties"
  end

  def routes
    if path = params[:path]
      path = URI::DEFAULT_PARSER.escape path
      normalized_path = with_leading_slash path
      render json: {
        exact: match_route { |it| it.match normalized_path },
        fuzzy: match_route { |it| it.spec.to_s.match path }
      }
    else
      @routes_table = routes_table
      @page_title = "Routes"
    end
  end

  private
    def routes_table
      text = Jets::Router::Help.new(format: "markdown").text
      Kramdown::Document.new(text).to_html
    end

    def match_route
      _routes.routes.filter_map { |route| route.path.spec.to_s if yield route.path }
    end

    def with_leading_slash(path)
      ("/" + path).squeeze("/")
    end
end
