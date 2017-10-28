get  "posts/:id", to: "posts#show"
post "posts", to: "posts#create"
put  "posts", to: "posts#update"
delete  "posts", to: "posts#destroy"
any "posts/hot", to: "posts#hot"
# resources :posts
