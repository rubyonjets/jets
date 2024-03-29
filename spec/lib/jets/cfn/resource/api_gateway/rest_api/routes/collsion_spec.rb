describe Jets::Cfn::Resource::ApiGateway::RestApi do
  let(:collision) do
    Jets::Cfn::Resource::ApiGateway::RestApi::Routes::Collision.new
  end

  context "collides" do
    it "variable_collision_exists?" do
      parent = "users"
      paths = %w[
        users/:user_id/posts/:id/edit
        users/:id
        posts/:id
        admin
      ]
      collide = collision.variable_collision_exists?(parent, paths)
      expect(collide).to be true
    end

    it "register collisions for later display" do
      parent = "users"
      paths = %w[
        users/:user_id/posts/:id/edit
        users/:id
        posts/:id
        admin
      ]
      collide = collision.variable_collision_exists?(parent, paths)
      expect(collide).to be true
    end
  end

  context "no collisions" do
    it "collision?" do
      paths = Jets.application.routes.routes.map(&:path)
      collide = collision.collision?(paths)
      expect(collide).to be false
    end

    it "variable_collision_exists?" do
      parent_path = "users"
      paths = %w[
        users/:user_id/posts/:id/edit
        users/:user_id
        posts/:id
        admin
      ]
      collide = collision.variable_collision_exists?(parent_path, paths)
      expect(collide).to be false
    end

    it "variable_collision_exists long path?" do
      parent_path = "users/:user_id/posts"
      paths = %w[
        users/:user_id
        users/:user_id/posts
        users/:user_id/posts/:id
        users/:user_id/posts/:id/edit
        users/:user_id/apps
        posts/:id
        admin
      ]
      collide = collision.variable_collision_exists?(parent_path, paths)
      expect(collide).to be false
    end

    # actual data
    it "variable_collision_exists? post crud" do
      parent_path = "posts"
      paths = ["posts", "posts/new", "posts/:id", "posts/:id/edit", "", "*catchall"]
      collide = collision.variable_collision_exists?(parent_path, paths)
      expect(collide).to be false
    end

    it "posts comments nested resources" do
      parent_path = "posts/:post_id/comments"
      paths = ["posts/:post_id/comments/:id", "posts/:post_id/comments/new"]
      collide = collision.variable_collision_exists?(parent_path, paths)
      expect(collide).to be false
    end
  end

  context "general" do
    it "variable_parent" do
      leaf = collision.variable_parent("users/:user_id/posts/:id/edit")
      expect(leaf).to eq "users/:user_id/posts"

      leaf = collision.variable_parent("users/:user_id")
      expect(leaf).to eq "users"

      leaf = collision.variable_parent("posts/:id")
      expect(leaf).to eq "posts"
    end

    it "variable_parents" do
      paths = %w[
        users/:user_id/posts/:id/edit
        users/:user_id
        posts/:id
        admin
      ]
      parents = collision.variable_parents(paths)
      expect(parents).to eq ["posts", "users", "users/:user_id/posts"]
    end

    it "parent_variables" do
      parent = "users"
      paths = %w[
        users/:user_id/posts/:post_id/edit
        users/:id
        posts/:id/users
        admin
      ]
      variables = collision.parent_variables(parent, paths)
      expect(variables).to eq [":id", ":user_id"]
    end

    it "direct_parent?" do
      parent = "users"
      path = "users/:id"
      is_parent = collision.direct_parent?(parent, path)
      expect(is_parent).to be true

      parent = "users"
      path = "posts/:id/users"
      is_parent = collision.direct_parent?(parent, path)
      expect(is_parent).to be false

      parent = "users"
      path = "users/:id/posts/:post_id"
      is_parent = collision.direct_parent?(parent, path)
      expect(is_parent).to be false

      parent = "users/:id/posts"
      path = "users/:id/posts/:post_id"
      is_parent = collision.direct_parent?(parent, path)
      expect(is_parent).to be true

      parent = "users"
      leaf = "users/:user_id/posts/:id"
      direct_parent = collision.direct_parent?(parent, leaf)
      expect(direct_parent).to be false

      parent = "users/:user_id/posts"
      leaf = "users/:user_id/posts/:id"
      direct_parent = collision.direct_parent?(parent, leaf)
      expect(direct_parent).to be true

      parent = "users"
      leaf = "users/:user_id"
      direct_parent = collision.direct_parent?(parent, leaf)
      expect(direct_parent).to be true
    end

    it "parent? does not have to be direct" do
      parent = "users"
      path = "users/:id"
      is_parent = collision.parent?(parent, path)
      expect(is_parent).to be true

      parent = "users"
      path = "posts/:id/users"
      is_parent = collision.parent?(parent, path)
      expect(is_parent).to be false

      parent = "users"
      path = "users/:id/posts/:post_id"
      is_parent = collision.parent?(parent, path)
      expect(is_parent).to be true

      parent = "users/:id/posts"
      path = "users/:id/posts/:post_id"
      is_parent = collision.parent?(parent, path)
      expect(is_parent).to be true
    end
  end
end
