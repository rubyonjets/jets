# Example routes.rb of resources
resources :posts

get "landing", to: "posts#index"

any "*catchall", to: "public_files#show"
