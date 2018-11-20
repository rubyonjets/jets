Jets.application.routes.draw do
  root "posts#index"

  resources :toys
  resources :posts
  # resources :posts expands to:
  # get "posts", to: "posts#index"
  # get "posts/new", to: "posts#new"
  # get "posts/:id", to: "posts#show"
  # post "posts", to: "posts#create"
  # get "posts/:id/edit", to: "posts#edit"
  # put "posts/:id", to: "posts#update"
  # delete "posts/:id", to: "posts#delete"

  any "comments/hot", to: "comments#hot"
  get "landing/posts", to: "posts#index"

  get "admin/pages", to: "admin/pages#index"
  get "related_posts/:id", to: "related_posts#show"

  resources :stores

  # to demo ActiveRecord support
  resources :articles

  any "others/*proxy", to: "others#catchall"
  # # jets routes these special paths to the JetsPublicFilesController
  # any "public/*proxy", to: "public_files#catchall"
  # any "javascripts/*proxy", to: "public_files#catchall"
  # any "stylesheets/*proxy", to: "public_files#catchall"

  # Catchall routes at the root level work differently in local development
  # than on AWS API Gateway.  Locally, the rack middleware routes the static
  # files directly never hits Jets.  On AWS though, there is no rack middleware
  # it's all API Gateway.  So for a root level catchall route like
  #
  #    any "*catchall", to: "public_files#show"
  #
  # It cannot be tested locally - at least, I'm don't how to do that yet.
  any "static/*catchall", to: "public_files#show"
  any "*catchall", to: "public_files#show"

  # public2/stylesheets/test.css
end
