# Detects path variable collisions
class Jets::Resource::ApiGateway::RestApi::Routes
  class Collision < Base
    autoload :VariableException, 'jets/resource/api_gateway/rest_api/routes/collision/variable_exception'

    attr_reader :collisions
    def initialize(routes)
      @routes = routes
      @collisions = []
    end

    def collision?
      paths = paths_with_variables(@routes.map(&:path))
      parents = variable_parents(paths)

      collide = false
      parents.each do |parent|
        collide ||= variable_collision_exists?(parent, paths)
      end
      collide
    end

    def exception
      collision_message = <<~EOL
        There are routes with sibling variables under the same parent that collide.

        Collisions:
          #{@collisions.join("\n  ")}

        API Gateway only allows one unique variable path You must use the same variable name within
        the same parent route path.
        Example: /posts/:id and /posts/:post_id/reveal should both be /posts/:id and /posts/:id/reveal.

        Please check your `config/routes.rb` and remove the colliding routes.
        More info: http://rubyonjets.com/docs/considerations-api-gateway/
      EOL
      VariableException.new(collision_message)
    end

    def variable_collision_exists?(parent, paths)
      paths = paths_with_variables(paths)
      variables = parent_variables(parent, paths)
      collide = variables.uniq.size > 1
      register_collision(parent, variables) if collide
      collide
    end

    # register collision for later display
    # We don't register the full path but this might be more helpful.
    def register_collision(parent, variables)
      return unless variables.uniq.size # check again just in case

      variables.each do |v|
        @collisions << "#{parent}/#{v}"
      end
      @collisions.uniq!
    end

    def parent_variables(parent, paths)
      paths = paths.select do |path|
        parent?(parent, path)
      end
      paths.map do |path|
        path.sub("#{parent}/",'').gsub(%r{/.*},'')
      end.uniq.sort
    end

    def parent?(parent, path)
      parent_parts = parent.split('/')
      path_parts = path.split('/')

      n = parent_parts.size-1
      parent_parts[0..n] == path_parts[0..n]
    end

    def direct_parent?(parent, path)
      leaf = variable_leaf(path)
      leaf_parent = leaf.split('/')[0..-2].join('/')
      parent == leaf_parent
    end

    def variable_parents(paths)
      parents = []
      paths = paths_with_variables(paths)
      paths.each do |path|
        parents << variable_parent(path)
      end
      parents.uniq.sort
    end

    def paths_with_variables(paths)
      paths.select { |p| p.include?(':') }.uniq
    end

    # Strips the path down until only the leaf node part is a variable
    # Example: users/:user_id/posts/:post_id/edit
    # Returns: users/:user_id/posts/:post_id
    def variable_parent(path)
      path = variable_leaf(path)
      # drop last variable to leave behind the parent
      path.split('/')[0..-2].join('/')
    end

    # Strips the path down until only the leaf node part is a variable
    # Example: users/:user_id/posts/:post_id/edit
    # Returns: users/:user_id/posts
    def variable_leaf(path)
      return unless path.include?(':')

      parts = path.split('/')
      is_variable = parts.last.include?(':')
      until is_variable
        parts.pop
        is_variable = parts.last.include?(':')
      end
      parts[0..-1].join('/') # parent
    end
  end
end