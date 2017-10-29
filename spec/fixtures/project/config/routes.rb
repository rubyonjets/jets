get "posts", to: "posts#index"
# gateway_method_logical_id: ApiGatewayMethodPostsControllerIndex
# function_name_logical_id: PostsControllerIndexLambdaFunction
get  "posts/:id", to: "posts#show"
# gateway_method_logical_id: ApiGatewayMethodPostsControllerShow
# function_name_logical_id: PostsControllerShowLambdaFunction

# post "posts", to: "posts#create"
# put  "posts", to: "posts#edit"
# put  "posts", to: "posts#update"
# delete  "posts", to: "posts#delete"

# any "comments/hot", to: "comments#hot"
# resources :posts
