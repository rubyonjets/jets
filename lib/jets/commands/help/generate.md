This piggy backs off of the [rails scaffold generator](https://guides.rubyonrails.org/command_line.html#rails-generate).

## Example

    $ jets generate scaffold Post title:string body:text published:boolean
          invoke  active_record
          create    db/migrate/20180817052529_create_posts.rb
          create    app/models/post.rb
          invoke  resource_route
           route    resources :posts
          invoke  scaffold_controller
          create    app/controllers/posts_controller.rb
          invoke    erb
          create      app/views/posts
          create      app/views/posts/index.html.erb
          create      app/views/posts/edit.html.erb
          create      app/views/posts/show.html.erb
          create      app/views/posts/new.html.erb
          create      app/views/posts/_form.html.erb
          invoke    helper
          create      app/helpers/posts_helper.rb
    $