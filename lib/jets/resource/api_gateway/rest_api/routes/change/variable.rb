# Detects route variable changes
class Jets::Resource::ApiGateway::RestApi::Routes::Change
  class Variable < Base
    def changed?
      changed = false
      deployed_routes.each do |deployed_route|
        parent = collision.variable_parent(deployed_route.path)
        parent_variables = collision.parent_variables(parent, [deployed_route.path])
        new_parent_variables = collision.parent_variables(parent, new_paths)

        changed = parent_variables.size > 0 && new_parent_variables.size > 0 &&
                  parent_variables != new_parent_variables
        break if changed
      end
      changed
    end

    # Only consider paths with variables
    def new_paths
      new_routes.map(&:path).select {|p| p.include?(':')}.uniq
    end

    # Only consider deployed routes with variables
    def deployed_routes
      deployed_routes = super
      deployed_routes.select do |route|
        route.path.include?(':')
      end
    end

    def collision
      @collision ||= Jets::Resource::ApiGateway::RestApi::Routes::Collision.new
    end
  end
end
