# get "posts", to: "posts#index"
# # logical_id: ApiGatewayMethodPostsControllerIndex
# # function_name_logical_id: PostsControllerIndexLambdaFunction
# get  "posts/:id", to: "posts#show"
# logical_id: ApiGatewayMethodPostsControllerShow
# function_name_logical_id: PostsControllerShowLambdaFunction

# post "posts", to: "posts#create"
# get  "posts/:id/edit", to: "posts#edit"
# put  "posts", to: "posts#update"
# delete  "posts", to: "posts#delete"

resources :posts

any "comments/hot", to: "comments#hot"

# get  "landing/posts", to: "posts#index" # posts/:id
# ApiGatewayResource at /landing
# ApiGatewayMethod that maps PostsControllerLanding to the resource

get  "landing/comments", to: "comments#hot" # posts/:id

