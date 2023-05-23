module Jets
  module Router
    class Error < RuntimeError ; end

    NAMED_ROUTES_METHODS = %w[index new create show edit update destroy].freeze

    def has_controller?(name)
      routes.detect { |r| r.controller_name == name }
    end

    def draw
      drawn_route_set
    end

    @@drawn_route_set = nil
    def drawn_route_set
      return @@drawn_route_set if @@drawn_route_set

      route_set = Jets.application.routes
      @@drawn_route_set = route_set
    end

    def clear!
      @@drawn_route_set = nil
    end

    def routes
      drawn_route_set.routes
    end

    # So we can save state in s3 post deploy. Example of structure.
    #
    #   [
    #     {"scope"=>{"options"=>{"as"=>"posts", "path"=>"posts", "param"=>nil, "from"=>"resources"}, "parent"=>{"options"=>{}, "parent"=>nil, "level"=>1}, "level"=>2}, "options"=>{"to"=>"posts#index", "path"=>"posts", "method"=>"get"}, "path"=>"posts", "to"=>"posts#index", "as"=>"posts"},
    #     {"scope"=>{"options"=>{"as"=>"posts", "path"=>"posts", "param"=>nil, "from"=>"resources"}, "parent"=>{"options"=>{}, "parent"=>nil, "level"=>1}, "level"=>2}, "options"=>{"to"=>"posts#new", "path"=>"posts/new", "method"=>"get"}, "path"=>"posts/new", "to"=>"posts#new", "as"=>"new_post"},
    #     ...
    #   ]
    #
    def to_json
      JSON.dump(routes.map(&:to_h))
    end

    # Returns all paths including subpaths.
    # Example:
    # Input: ["posts/:id/edit"]
    # Output: ["posts", "posts/:id", "posts/:id/edit"]
    def all_paths
      drawn_route_set.all_paths
    end

    def all_routes_valid?
      invalid_routes.empty?
    end

    def invalid_routes
      routes.select { |r| !r.valid? }
    end

    def validate_routes!
      return true if Jets.config.cfn.build.routes == "one_apigw_method_for_all_routes"
      check_route_connected_functions
    end

    # Checks that all routes are validate and have corresponding lambda functions
    def check_route_connected_functions
      return true if all_routes_valid?

      puts "Please double check the routes below map to valid controllers:".color(:red)
      invalid_routes.each do |route|
        puts "  /#{route.path} => #{route.controller_name}##{route.action_name}"
      end
      false
    end

    def find_route_by_event(event)
      request = Jets::Controller::Request.new(event: event)
      Jets::Router::Matcher.new.find_by_request(request)
    end

    def find_by_definition(definition)
      routes.find do |route|
        route.controller_name == definition.class_name &&
        route.action_name == definition.meth.to_s
      end
    end

    # Filters out internal routes
    def no_routes?
      routes.reject(&:internal?).empty?
    end

    extend self
  end
end