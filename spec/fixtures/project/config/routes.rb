resources :posts
# resources :posts expands to:
# get "posts", to: "posts#index"
# get "posts/new", to: "posts#new"
# get "posts/:id", to: "posts#show"
# post "posts", to: "posts#create"
# get "posts/:id/edit", to: "posts#edit"
# put "posts/:id", to: "posts#update"
# delete "posts/:id", to: "posts#delete"

# get "comments", to: "comments#index"
# get "comments/new", to: "comments#new"
# get "comments/:id", to: "comments#show"
# post "comments", to: "comments#create"
# get "comments/:id/edit", to: "comments#edit"
# put "comments/:id", to: "comments#update"
# delete "comments/:id", to: "comments#delete"

get "admin/pages", to: "admin/pages#index"

any "comments/hot", to: "comments#hot"
get "landing/posts", to: "posts#index"
get "landing/comments", to: "comments#hot"
