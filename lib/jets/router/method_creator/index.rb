class Jets::Router::MethodCreator
  class Index < Code
    def meth_name
      # TODO: figure out how to improve this and make easier to follow.
      #
      # Example 1:
      #
      #     resources :users, only: [] do
      #       resources :posts, only: :index
      #     end
      #
      # Results in:
      #
      #     full_as: user_posts
      #     method_name_leaf: nil
      #
      # Example 2:
      #
      #     resources :users, only: [] do
      #       get "posts", to: "posts#index"
      #     end
      #
      # Results in:
      #
      #     full_as: users
      #     method_name_leaf: posts
      #
      # This is because using resources contains all the info we need in parent scopes.
      # The scope.full_as already has the desired meth_name.
      #
      # However, when using the simple create_route methods like get, the parent scope does not contain
      # all the info we need. In this tricky case, the method_name_leaf is set.
      # We then have to reconstruct the meth_name.
      #

      if method_name_leaf
        path_items = @path.to_s.split('/')
        if path_items.size == 1
          join(singularize(full_as), method_name_leaf) # reconstruct
        else
          nil # fallback: do not define url method
        end
      else  # comes from resources
        join(full_as) # construct entirely from scope info
      end
    end
  end
end
