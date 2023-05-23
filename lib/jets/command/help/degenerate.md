This piggy backs off of the [rails scaffold destroy](https://guides.rubyonrails.org/command_line.html#rails-destroy).

## Example

    $ jets degenerate scaffold post title:string body:text published:boolean
          invoke  active_record
          remove    db/migrate/20190225231821_create_posts.rb
          remove    app/models/post.rb
          invoke  resource_route
          route    resources :posts
          invoke  scaffold_controller
          remove    app/controllers/posts_controller.rb
          invoke    erb
          invoke    helper
          remove      app/helpers/posts_helper.rb
    $
