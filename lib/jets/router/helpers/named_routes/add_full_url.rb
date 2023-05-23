module Jets::Router::Helpers::NamedRoutes
  module AddFullUrl
    # Named add_full_url to avoid mental conflicts with Jets full_url_for
    # Leverage Rails URL.url_for to avoid duplicating the logic
    # Rails sets url_strategy to:
    #     => ActionDispatch::Routing::RouteSet::UNKNOWN
    #     => ActionDispatch::Http::URL.url_for(options)
    def add_full_url(options)
      options = url_options.merge(options)
      ActionDispatch::Http::URL.url_for(options)
    end
  end
end
