class RouterTestApp
  include Jets::Router::Helpers::NamedRoutesHelper
end

describe Jets::Router do
  let(:router)  { Jets::Router.new }
  let(:app)     { RouterTestApp.new }
  before(:each) { Jets::Router::Helpers::NamedRoutesHelper.clear! }

  describe "Router" do
    context "plural resources" do
      it "only option posts comments" do
        router.draw do
          resources :posts, only: :new do
            resources :comments, only: [:edit]
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------------------+------+----------------------------------+-------------------+
|        As         | Verb |               Path               | Controller#action |
+-------------------+------+----------------------------------+-------------------+
| new_post          | GET  | posts/new                        | posts#new         |
| edit_post_comment | GET  | posts/:post_id/comments/:id/edit | comments#edit     |
+-------------------+------+----------------------------------+-------------------+
EOL
        expect(output).to eq(table)
        expect(router.routes).to be_a(Array)
        expect(router.routes.first).to be_a(Jets::Router::Route)
      end

      it "nested with another resources posts comments" do
        router.draw do
          resources :posts do
            resources :comments
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------------------+--------+----------------------------------+-------------------+
|        As         |  Verb  |               Path               | Controller#action |
+-------------------+--------+----------------------------------+-------------------+
| posts             | GET    | posts                            | posts#index       |
| new_post          | GET    | posts/new                        | posts#new         |
| post              | GET    | posts/:post_id                   | posts#show        |
|                   | POST   | posts                            | posts#create      |
| edit_post         | GET    | posts/:post_id/edit              | posts#edit        |
|                   | PUT    | posts/:post_id                   | posts#update      |
|                   | POST   | posts/:post_id                   | posts#update      |
|                   | PATCH  | posts/:post_id                   | posts#update      |
|                   | DELETE | posts/:post_id                   | posts#delete      |
| post_comments     | GET    | posts/:post_id/comments          | comments#index    |
| new_post_comment  | GET    | posts/:post_id/comments/new      | comments#new      |
| post_comment      | GET    | posts/:post_id/comments/:id      | comments#show     |
|                   | POST   | posts/:post_id/comments          | comments#create   |
| edit_post_comment | GET    | posts/:post_id/comments/:id/edit | comments#edit     |
|                   | PUT    | posts/:post_id/comments/:id      | comments#update   |
|                   | POST   | posts/:post_id/comments/:id      | comments#update   |
|                   | PATCH  | posts/:post_id/comments/:id      | comments#update   |
|                   | DELETE | posts/:post_id/comments/:id      | comments#delete   |
+-------------------+--------+----------------------------------+-------------------+
EOL
        expect(output).to eq(table)

        expect(app.posts_path).to eq("/posts")
        expect(app.new_post_path).to eq("/posts/new")
        expect(app.post_path(1)).to eq("/posts/1")
        expect(app.edit_post_path(1)).to eq("/posts/1/edit")

        expect(app.post_comments_path(1)).to eq("/posts/1/comments")
        expect(app.new_post_comment_path(1)).to eq("/posts/1/comments/new")
        expect(app.post_comment_path(1, 2)).to eq("/posts/1/comments/2")
        expect(app.edit_post_comment_path(1, 2)).to eq("/posts/1/comments/2/edit")
      end

      it "member and collection" do
        router.draw do
          resources :accounts, only: [] do
            get :photo, on: :member
            get :comments, on: :collection
          end
        end
        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------------------+------+----------------------------+-------------------+
|        As         | Verb |            Path            | Controller#action |
+-------------------+------+----------------------------+-------------------+
| photo_account     | GET  | accounts/:account_id/photo | accounts#photo    |
| comments_accounts | GET  | accounts/comments          | accounts#comments |
+-------------------+------+----------------------------+-------------------+
EOL
        expect(output).to eq(table)

        expect(app.photo_account_path(1)).to eq("/accounts/1/photo")
        expect(app.comments_accounts_path).to eq("/accounts/comments")
      end
    end

    context "plural resources options" do
      it "as articles" do
        router.draw do
          resources :posts, as: "articles"
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+--------------+--------+----------------+-------------------+
|      As      |  Verb  |      Path      | Controller#action |
+--------------+--------+----------------+-------------------+
| articles     | GET    | posts          | posts#index       |
| new_article  | GET    | posts/new      | posts#new         |
| article      | GET    | posts/:id      | posts#show        |
|              | POST   | posts          | posts#create      |
| edit_article | GET    | posts/:id/edit | posts#edit        |
|              | PUT    | posts/:id      | posts#update      |
|              | POST   | posts/:id      | posts#update      |
|              | PATCH  | posts/:id      | posts#update      |
|              | DELETE | posts/:id      | posts#delete      |
+--------------+--------+----------------+-------------------+
EOL
        expect(output).to eq(table)

        expect(app.articles_path).to eq("/posts")
        expect(app.new_article_path).to eq("/posts/new")
        expect(app.article_path(1)).to eq("/posts/1")
        expect(app.edit_article_path(1)).to eq("/posts/1/edit")
      end

      it "module admin" do
        router.draw do
          resources :posts, module: "admin"
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-----------+--------+----------------+--------------------+
|    As     |  Verb  |      Path      | Controller#action  |
+-----------+--------+----------------+--------------------+
| posts     | GET    | posts          | admin/posts#index  |
| new_post  | GET    | posts/new      | admin/posts#new    |
| post      | GET    | posts/:id      | admin/posts#show   |
|           | POST   | posts          | admin/posts#create |
| edit_post | GET    | posts/:id/edit | admin/posts#edit   |
|           | PUT    | posts/:id      | admin/posts#update |
|           | POST   | posts/:id      | admin/posts#update |
|           | PATCH  | posts/:id      | admin/posts#update |
|           | DELETE | posts/:id      | admin/posts#delete |
+-----------+--------+----------------+--------------------+
EOL
        expect(output).to eq(table)

        expect(app.posts_path).to eq("/posts")
        expect(app.new_post_path).to eq("/posts/new")
        expect(app.post_path(1)).to eq("/posts/1")
        expect(app.edit_post_path(1)).to eq("/posts/1/edit")
      end

      it "prefix admin" do
        router.draw do
          resources :posts, prefix: "admin"
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-----------+--------+----------------------+-------------------+
|    As     |  Verb  |         Path         | Controller#action |
+-----------+--------+----------------------+-------------------+
| posts     | GET    | admin/posts          | posts#index       |
| new_post  | GET    | admin/posts/new      | posts#new         |
| post      | GET    | admin/posts/:id      | posts#show        |
|           | POST   | admin/posts          | posts#create      |
| edit_post | GET    | admin/posts/:id/edit | posts#edit        |
|           | PUT    | admin/posts/:id      | posts#update      |
|           | POST   | admin/posts/:id      | posts#update      |
|           | PATCH  | admin/posts/:id      | posts#update      |
|           | DELETE | admin/posts/:id      | posts#delete      |
+-----------+--------+----------------------+-------------------+
EOL
        expect(output).to eq(table)

        expect(app.posts_path).to eq("/admin/posts")
        expect(app.new_post_path).to eq("/admin/posts/new")
        expect(app.post_path(1)).to eq("/admin/posts/1")
        expect(app.edit_post_path(1)).to eq("/admin/posts/1/edit")
      end

      it "prefix with nested resources comments" do
        router.draw do
          resources :posts, prefix: "admin" do
            resources :comments
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------------------+--------+----------------------------------------+-------------------+
|        As         |  Verb  |                  Path                  | Controller#action |
+-------------------+--------+----------------------------------------+-------------------+
| posts             | GET    | admin/posts                            | posts#index       |
| new_post          | GET    | admin/posts/new                        | posts#new         |
| post              | GET    | admin/posts/:post_id                   | posts#show        |
|                   | POST   | admin/posts                            | posts#create      |
| edit_post         | GET    | admin/posts/:post_id/edit              | posts#edit        |
|                   | PUT    | admin/posts/:post_id                   | posts#update      |
|                   | POST   | admin/posts/:post_id                   | posts#update      |
|                   | PATCH  | admin/posts/:post_id                   | posts#update      |
|                   | DELETE | admin/posts/:post_id                   | posts#delete      |
| post_comments     | GET    | admin/posts/:post_id/comments          | comments#index    |
| new_post_comment  | GET    | admin/posts/:post_id/comments/new      | comments#new      |
| post_comment      | GET    | admin/posts/:post_id/comments/:id      | comments#show     |
|                   | POST   | admin/posts/:post_id/comments          | comments#create   |
| edit_post_comment | GET    | admin/posts/:post_id/comments/:id/edit | comments#edit     |
|                   | PUT    | admin/posts/:post_id/comments/:id      | comments#update   |
|                   | POST   | admin/posts/:post_id/comments/:id      | comments#update   |
|                   | PATCH  | admin/posts/:post_id/comments/:id      | comments#update   |
|                   | DELETE | admin/posts/:post_id/comments/:id      | comments#delete   |
+-------------------+--------+----------------------------------------+-------------------+
EOL
        expect(output).to eq(table)

        expect(app.posts_path).to eq("/admin/posts")
        expect(app.new_post_path).to eq("/admin/posts/new")
        expect(app.post_path(1)).to eq("/admin/posts/1")
        expect(app.edit_post_path(1)).to eq("/admin/posts/1/edit")

        expect(app.post_comments_path(1)).to eq("/admin/posts/1/comments")
        expect(app.new_post_comment_path(1)).to eq("/admin/posts/1/comments/new")
        expect(app.post_comment_path(1, 2)).to eq("/admin/posts/1/comments/2")
        expect(app.edit_post_comment_path(1, 2)).to eq("/admin/posts/1/comments/2/edit")
      end

      it "controller articles" do
        router.draw do
          resources :posts, controller: "articles"
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-----------+--------+----------------+-------------------+
|    As     |  Verb  |      Path      | Controller#action |
+-----------+--------+----------------+-------------------+
| posts     | GET    | posts          | articles#index    |
| new_post  | GET    | posts/new      | articles#new      |
| post      | GET    | posts/:id      | articles#show     |
|           | POST   | posts          | articles#create   |
| edit_post | GET    | posts/:id/edit | articles#edit     |
|           | PUT    | posts/:id      | articles#update   |
|           | POST   | posts/:id      | articles#update   |
|           | PATCH  | posts/:id      | articles#update   |
|           | DELETE | posts/:id      | articles#delete   |
+-----------+--------+----------------+-------------------+
EOL
        expect(output).to eq(table)

        expect(app.posts_path).to eq("/posts")
        expect(app.new_post_path).to eq("/posts/new")
        expect(app.post_path(1)).to eq("/posts/1")
        expect(app.edit_post_path(1)).to eq("/posts/1/edit")
      end

      it "controller with namespace admin/posts" do
        router.draw do
          resources :posts, controller: "admin/posts"
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-----------+--------+----------------+--------------------+
|    As     |  Verb  |      Path      | Controller#action  |
+-----------+--------+----------------+--------------------+
| posts     | GET    | posts          | admin/posts#index  |
| new_post  | GET    | posts/new      | admin/posts#new    |
| post      | GET    | posts/:id      | admin/posts#show   |
|           | POST   | posts          | admin/posts#create |
| edit_post | GET    | posts/:id/edit | admin/posts#edit   |
|           | PUT    | posts/:id      | admin/posts#update |
|           | POST   | posts/:id      | admin/posts#update |
|           | PATCH  | posts/:id      | admin/posts#update |
|           | DELETE | posts/:id      | admin/posts#delete |
+-----------+--------+----------------+--------------------+
EOL
        expect(output).to eq(table)

        expect(app.posts_path).to eq("/posts")
        expect(app.new_post_path).to eq("/posts/new")
        expect(app.post_path(1)).to eq("/posts/1")
        expect(app.edit_post_path(1)).to eq("/posts/1/edit")
      end

      it "param custom my_comment_id" do
        router.draw do
          resources :posts do
            resources :comments, param: :my_comment_id
          end
          resources :users, param: :my_user_id
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------------------+--------+---------------------------------------------+-------------------+
|        As         |  Verb  |                    Path                     | Controller#action |
+-------------------+--------+---------------------------------------------+-------------------+
| posts             | GET    | posts                                       | posts#index       |
| new_post          | GET    | posts/new                                   | posts#new         |
| post              | GET    | posts/:post_id                              | posts#show        |
|                   | POST   | posts                                       | posts#create      |
| edit_post         | GET    | posts/:post_id/edit                         | posts#edit        |
|                   | PUT    | posts/:post_id                              | posts#update      |
|                   | POST   | posts/:post_id                              | posts#update      |
|                   | PATCH  | posts/:post_id                              | posts#update      |
|                   | DELETE | posts/:post_id                              | posts#delete      |
| post_comments     | GET    | posts/:post_id/comments                     | comments#index    |
| new_post_comment  | GET    | posts/:post_id/comments/new                 | comments#new      |
| post_comment      | GET    | posts/:post_id/comments/:my_comment_id      | comments#show     |
|                   | POST   | posts/:post_id/comments                     | comments#create   |
| edit_post_comment | GET    | posts/:post_id/comments/:my_comment_id/edit | comments#edit     |
|                   | PUT    | posts/:post_id/comments/:my_comment_id      | comments#update   |
|                   | POST   | posts/:post_id/comments/:my_comment_id      | comments#update   |
|                   | PATCH  | posts/:post_id/comments/:my_comment_id      | comments#update   |
|                   | DELETE | posts/:post_id/comments/:my_comment_id      | comments#delete   |
| users             | GET    | users                                       | users#index       |
| new_user          | GET    | users/new                                   | users#new         |
| user              | GET    | users/:my_user_id                           | users#show        |
|                   | POST   | users                                       | users#create      |
| edit_user         | GET    | users/:my_user_id/edit                      | users#edit        |
|                   | PUT    | users/:my_user_id                           | users#update      |
|                   | POST   | users/:my_user_id                           | users#update      |
|                   | PATCH  | users/:my_user_id                           | users#update      |
|                   | DELETE | users/:my_user_id                           | users#delete      |
+-------------------+--------+---------------------------------------------+-------------------+
EOL
        expect(output).to eq(table)

        expect(app.users_path).to eq("/users")
        expect(app.new_user_path).to eq("/users/new")
        expect(app.user_path(1)).to eq("/users/1")
        expect(app.edit_user_path(1)).to eq("/users/1/edit")
      end

      it "param custom my_comment_id with block" do
        router.draw do
          resources :posts do
            resources :comments, param: :my_comment_id, only: [:create] do
              get :test, on: :member
            end
          end

          resources :parent, param: :my_parent_id do
            resources :child, only: [:create, :show], param: :my_child_id do
              # nothing
            end
          end

          resources :users, param: :my_user_id, only: [] do
            get :test, on: :member
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+--------------+--------+---------------------------------------------+-------------------+
|      As      |  Verb  |                    Path                     | Controller#action |
+--------------+--------+---------------------------------------------+-------------------+
| posts        | GET    | posts                                       | posts#index       |
| new_post     | GET    | posts/new                                   | posts#new         |
| post         | GET    | posts/:post_id                              | posts#show        |
|              | POST   | posts                                       | posts#create      |
| edit_post    | GET    | posts/:post_id/edit                         | posts#edit        |
|              | PUT    | posts/:post_id                              | posts#update      |
|              | POST   | posts/:post_id                              | posts#update      |
|              | PATCH  | posts/:post_id                              | posts#update      |
|              | DELETE | posts/:post_id                              | posts#delete      |
|              | POST   | posts/:post_id/comments                     | comments#create   |
| test_comment | GET    | posts/:post_id/comments/:my_comment_id/test | comments#test     |
| parent       | GET    | parent                                      | parent#index      |
| new_parent   | GET    | parent/new                                  | parent#new        |
| parent       | GET    | parent/:my_parent_id                        | parent#show       |
|              | POST   | parent                                      | parent#create     |
| edit_parent  | GET    | parent/:my_parent_id/edit                   | parent#edit       |
|              | PUT    | parent/:my_parent_id                        | parent#update     |
|              | POST   | parent/:my_parent_id                        | parent#update     |
|              | PATCH  | parent/:my_parent_id                        | parent#update     |
|              | DELETE | parent/:my_parent_id                        | parent#delete     |
| parent_child | GET    | parent/:my_parent_id/child/:my_child_id     | child#show        |
|              | POST   | parent/:my_parent_id/child                  | child#create      |
| test_user    | GET    | users/:my_user_id/test                      | users#test        |
+--------------+--------+---------------------------------------------+-------------------+
EOL
        expect(output).to eq(table)
      end
    end

    context "singular resource" do
      it "profile" do
        router.draw do
          resource :profile
        end

        output = Jets::Router.help(router.routes).to_s
        # There is no index route for the singular resource
        table =<<EOL
+--------------+--------+--------------+-------------------+
|      As      |  Verb  |     Path     | Controller#action |
+--------------+--------+--------------+-------------------+
| new_profile  | GET    | profile/new  | profiles#new      |
| profile      | GET    | profile      | profiles#show     |
|              | POST   | profile      | profiles#create   |
| edit_profile | GET    | profile/edit | profiles#edit     |
|              | PUT    | profile      | profiles#update   |
|              | POST   | profile      | profiles#update   |
|              | PATCH  | profile      | profiles#update   |
|              | DELETE | profile      | profiles#delete   |
+--------------+--------+--------------+-------------------+
EOL
        expect(output).to eq(table)

        expect(app.new_profile_path).to eq("/profile/new")
        expect(app.profile_path).to eq("/profile")
        expect(app.edit_profile_path).to eq("/profile/edit")
      end

      it "nested resources profile" do
        router.draw do
          resources :users do
            resource :profile
          end
        end

        output = Jets::Router.help(router.routes).to_s
        # There is no index route for the singular resource
        table =<<EOL
+-------------------+--------+-----------------------------+-------------------+
|        As         |  Verb  |            Path             | Controller#action |
+-------------------+--------+-----------------------------+-------------------+
| users             | GET    | users                       | users#index       |
| new_user          | GET    | users/new                   | users#new         |
| user              | GET    | users/:user_id              | users#show        |
|                   | POST   | users                       | users#create      |
| edit_user         | GET    | users/:user_id/edit         | users#edit        |
|                   | PUT    | users/:user_id              | users#update      |
|                   | POST   | users/:user_id              | users#update      |
|                   | PATCH  | users/:user_id              | users#update      |
|                   | DELETE | users/:user_id              | users#delete      |
| new_user_profile  | GET    | users/:user_id/profile/new  | profiles#new      |
| user_profile      | GET    | users/:user_id/profile      | profiles#show     |
|                   | POST   | users/:user_id/profile      | profiles#create   |
| edit_user_profile | GET    | users/:user_id/profile/edit | profiles#edit     |
|                   | PUT    | users/:user_id/profile      | profiles#update   |
|                   | POST   | users/:user_id/profile      | profiles#update   |
|                   | PATCH  | users/:user_id/profile      | profiles#update   |
|                   | DELETE | users/:user_id/profile      | profiles#delete   |
+-------------------+--------+-----------------------------+-------------------+
EOL
        expect(output).to eq(table)

        expect(app.users_path).to eq("/users")
        expect(app.new_user_path).to eq("/users/new")
        expect(app.user_path(1)).to eq("/users/1")
        expect(app.edit_user_path(1)).to eq("/users/1/edit")

        expect(app.new_user_profile_path(1)).to eq("/users/1/profile/new")
        expect(app.user_profile_path(1)).to eq("/users/1/profile")
        expect(app.edit_user_profile_path(1)).to eq("/users/1/profile/edit")
      end

      it "nested namespace profile" do
        router.draw do
          namespace :admin do
            resource :profile
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+--------------------+--------+--------------------+-----------------------+
|         As         |  Verb  |        Path        |   Controller#action   |
+--------------------+--------+--------------------+-----------------------+
| new_admin_profile  | GET    | admin/profile/new  | admin/profiles#new    |
| admin_profile      | GET    | admin/profile      | admin/profiles#show   |
|                    | POST   | admin/profile      | admin/profiles#create |
| edit_admin_profile | GET    | admin/profile/edit | admin/profiles#edit   |
|                    | PUT    | admin/profile      | admin/profiles#update |
|                    | POST   | admin/profile      | admin/profiles#update |
|                    | PATCH  | admin/profile      | admin/profiles#update |
|                    | DELETE | admin/profile      | admin/profiles#delete |
+--------------------+--------+--------------------+-----------------------+
EOL
        expect(output).to eq(table)

        expect(app.new_admin_profile_path).to eq("/admin/profile/new")
        expect(app.admin_profile_path).to eq("/admin/profile")
        expect(app.edit_admin_profile_path).to eq("/admin/profile/edit")
      end

      it "member and collection" do
        router.draw do
          resource :profile do
            get "photo", on: :member
            get "comments", on: :collection
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+------------------+--------+------------------+-------------------+
|        As        |  Verb  |       Path       | Controller#action |
+------------------+--------+------------------+-------------------+
| new_profile      | GET    | profile/new      | profiles#new      |
| profile          | GET    | profile          | profiles#show     |
|                  | POST   | profile          | profiles#create   |
| edit_profile     | GET    | profile/edit     | profiles#edit     |
|                  | PUT    | profile          | profiles#update   |
|                  | POST   | profile          | profiles#update   |
|                  | PATCH  | profile          | profiles#update   |
|                  | DELETE | profile          | profiles#delete   |
| photo_profile    | GET    | profile/photo    | profile#photo     |
| comments_profile | GET    | profile/comments | profile#comments  |
+------------------+--------+------------------+-------------------+
EOL
        expect(output).to eq(table)

        expect(app.new_profile_path).to eq("/profile/new")
        expect(app.profile_path).to eq("/profile")
        expect(app.edit_profile_path).to eq("/profile/edit")
        expect(app.photo_profile_path).to eq("/profile/photo")
        expect(app.comments_profile_path).to eq("/profile/comments")
      end

      it "as option" do
        router.draw do
          resource :profile, as: :account
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+--------------+--------+--------------+-------------------+
|      As      |  Verb  |     Path     | Controller#action |
+--------------+--------+--------------+-------------------+
| new_account  | GET    | profile/new  | profiles#new      |
| account      | GET    | profile      | profiles#show     |
|              | POST   | profile      | profiles#create   |
| edit_account | GET    | profile/edit | profiles#edit     |
|              | PUT    | profile      | profiles#update   |
|              | POST   | profile      | profiles#update   |
|              | PATCH  | profile      | profiles#update   |
|              | DELETE | profile      | profiles#delete   |
+--------------+--------+--------------+-------------------+
EOL
        expect(output).to eq(table)

        expect(app.new_account_path).to eq("/profile/new")
        expect(app.account_path).to eq("/profile")
        expect(app.edit_account_path).to eq("/profile/edit")
      end
    end

    context "nested resources" do
      it "plural to plural" do
        router.draw do
          resources :posts do
            resources :comments
          end
        end
        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------------------+--------+----------------------------------+-------------------+
|        As         |  Verb  |               Path               | Controller#action |
+-------------------+--------+----------------------------------+-------------------+
| posts             | GET    | posts                            | posts#index       |
| new_post          | GET    | posts/new                        | posts#new         |
| post              | GET    | posts/:post_id                   | posts#show        |
|                   | POST   | posts                            | posts#create      |
| edit_post         | GET    | posts/:post_id/edit              | posts#edit        |
|                   | PUT    | posts/:post_id                   | posts#update      |
|                   | POST   | posts/:post_id                   | posts#update      |
|                   | PATCH  | posts/:post_id                   | posts#update      |
|                   | DELETE | posts/:post_id                   | posts#delete      |
| post_comments     | GET    | posts/:post_id/comments          | comments#index    |
| new_post_comment  | GET    | posts/:post_id/comments/new      | comments#new      |
| post_comment      | GET    | posts/:post_id/comments/:id      | comments#show     |
|                   | POST   | posts/:post_id/comments          | comments#create   |
| edit_post_comment | GET    | posts/:post_id/comments/:id/edit | comments#edit     |
|                   | PUT    | posts/:post_id/comments/:id      | comments#update   |
|                   | POST   | posts/:post_id/comments/:id      | comments#update   |
|                   | PATCH  | posts/:post_id/comments/:id      | comments#update   |
|                   | DELETE | posts/:post_id/comments/:id      | comments#delete   |
+-------------------+--------+----------------------------------+-------------------+
EOL
        expect(output).to eq(table)

        expect(app.posts_path).to eq("/posts")
        expect(app.new_post_path).to eq("/posts/new")
        expect(app.post_path(1)).to eq("/posts/1")
        expect(app.edit_post_path(1)).to eq("/posts/1/edit")

        expect(app.post_comments_path(1)).to eq("/posts/1/comments")
        expect(app.new_post_comment_path(1)).to eq("/posts/1/comments/new")
        expect(app.post_comment_path(1,2)).to eq("/posts/1/comments/2")
        expect(app.edit_post_comment_path(1,2)).to eq("/posts/1/comments/2/edit")
      end

      it "singular to plural" do
        router.draw do
          resource :account do
            resources :api_keys
          end
        end
        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+----------------------+--------+---------------------------+-------------------+
|          As          |  Verb  |           Path            | Controller#action |
+----------------------+--------+---------------------------+-------------------+
| new_account          | GET    | account/new               | accounts#new      |
| account              | GET    | account                   | accounts#show     |
|                      | POST   | account                   | accounts#create   |
| edit_account         | GET    | account/edit              | accounts#edit     |
|                      | PUT    | account                   | accounts#update   |
|                      | POST   | account                   | accounts#update   |
|                      | PATCH  | account                   | accounts#update   |
|                      | DELETE | account                   | accounts#delete   |
| account_api_keys     | GET    | account/api_keys          | api_keys#index    |
| new_account_api_key  | GET    | account/api_keys/new      | api_keys#new      |
| account_api_key      | GET    | account/api_keys/:id      | api_keys#show     |
|                      | POST   | account/api_keys          | api_keys#create   |
| edit_account_api_key | GET    | account/api_keys/:id/edit | api_keys#edit     |
|                      | PUT    | account/api_keys/:id      | api_keys#update   |
|                      | POST   | account/api_keys/:id      | api_keys#update   |
|                      | PATCH  | account/api_keys/:id      | api_keys#update   |
|                      | DELETE | account/api_keys/:id      | api_keys#delete   |
+----------------------+--------+---------------------------+-------------------+
EOL
        expect(output).to eq(table)

        expect(app.new_account_path).to eq("/account/new")
        expect(app.account_path).to eq("/account")
        expect(app.edit_account_path).to eq("/account/edit")

        expect(app.account_api_keys_path).to eq("/account/api_keys")
        expect(app.new_account_api_key_path).to eq("/account/api_keys/new")
        expect(app.account_api_key_path(1)).to eq("/account/api_keys/1")
        expect(app.edit_account_api_key_path(1)).to eq("/account/api_keys/1/edit")
      end

      it "plural to singular" do
        router.draw do
          resources :books do
            resource :cover
          end
        end
        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-----------------+--------+---------------------------+-------------------+
|       As        |  Verb  |           Path            | Controller#action |
+-----------------+--------+---------------------------+-------------------+
| books           | GET    | books                     | books#index       |
| new_book        | GET    | books/new                 | books#new         |
| book            | GET    | books/:book_id            | books#show        |
|                 | POST   | books                     | books#create      |
| edit_book       | GET    | books/:book_id/edit       | books#edit        |
|                 | PUT    | books/:book_id            | books#update      |
|                 | POST   | books/:book_id            | books#update      |
|                 | PATCH  | books/:book_id            | books#update      |
|                 | DELETE | books/:book_id            | books#delete      |
| new_book_cover  | GET    | books/:book_id/cover/new  | covers#new        |
| book_cover      | GET    | books/:book_id/cover      | covers#show       |
|                 | POST   | books/:book_id/cover      | covers#create     |
| edit_book_cover | GET    | books/:book_id/cover/edit | covers#edit       |
|                 | PUT    | books/:book_id/cover      | covers#update     |
|                 | POST   | books/:book_id/cover      | covers#update     |
|                 | PATCH  | books/:book_id/cover      | covers#update     |
|                 | DELETE | books/:book_id/cover      | covers#delete     |
+-----------------+--------+---------------------------+-------------------+
EOL
        expect(output).to eq(table)

        expect(app.books_path).to eq("/books")
        expect(app.new_book_path).to eq("/books/new")
        expect(app.book_path(1)).to eq("/books/1")
        expect(app.edit_book_path(1)).to eq("/books/1/edit")

        expect(app.new_book_cover_path(1)).to eq("/books/1/cover/new")
        expect(app.book_cover_path(1)).to eq("/books/1/cover")
        expect(app.edit_book_cover_path(1)).to eq("/books/1/cover/edit")
      end

      it "singular to singular" do
        router.draw do
          resource :account do
            resource :avatar
          end
        end
        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+---------------------+--------+---------------------+-------------------+
|         As          |  Verb  |        Path         | Controller#action |
+---------------------+--------+---------------------+-------------------+
| new_account         | GET    | account/new         | accounts#new      |
| account             | GET    | account             | accounts#show     |
|                     | POST   | account             | accounts#create   |
| edit_account        | GET    | account/edit        | accounts#edit     |
|                     | PUT    | account             | accounts#update   |
|                     | POST   | account             | accounts#update   |
|                     | PATCH  | account             | accounts#update   |
|                     | DELETE | account             | accounts#delete   |
| new_account_avatar  | GET    | account/avatar/new  | avatars#new       |
| account_avatar      | GET    | account/avatar      | avatars#show      |
|                     | POST   | account/avatar      | avatars#create    |
| edit_account_avatar | GET    | account/avatar/edit | avatars#edit      |
|                     | PUT    | account/avatar      | avatars#update    |
|                     | POST   | account/avatar      | avatars#update    |
|                     | PATCH  | account/avatar      | avatars#update    |
|                     | DELETE | account/avatar      | avatars#delete    |
+---------------------+--------+---------------------+-------------------+
EOL
        expect(output).to eq(table)

        expect(app.new_account_path).to eq("/account/new")
        expect(app.account_path).to eq("/account")
        expect(app.edit_account_path).to eq("/account/edit")

        expect(app.new_account_avatar_path).to eq("/account/avatar/new")
        expect(app.account_avatar_path).to eq("/account/avatar")
        expect(app.edit_account_avatar_path).to eq("/account/avatar/edit")
      end
    end

    context "member and collection" do
      it "direct option" do
        router.draw do
          resources :posts, only: [] do
            get "preview", on: :member
            get "list", on: :collection
          end
        end
        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+--------------+------+------------------------+-------------------+
|      As      | Verb |          Path          | Controller#action |
+--------------+------+------------------------+-------------------+
| preview_post | GET  | posts/:post_id/preview | posts#preview     |
| list_posts   | GET  | posts/list             | posts#list        |
+--------------+------+------------------------+-------------------+
EOL
        expect(output).to eq(table)

        expect(app.preview_post_path(1)).to eq("/posts/1/preview")
        expect(app.list_posts_path).to eq("/posts/list")
      end

      it "nested resources member" do
        router.draw do
          resources :posts, only: [] do
            member do
              get "preview"
            end
            collection do
              get "list"
            end
          end
        end
        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+--------------+------+------------------------+-------------------+
|      As      | Verb |          Path          | Controller#action |
+--------------+------+------------------------+-------------------+
| preview_post | GET  | posts/:post_id/preview | posts#preview     |
| list_posts   | GET  | posts/list             | posts#list        |
+--------------+------+------------------------+-------------------+
EOL
        expect(output).to eq(table)

        expect(app.preview_post_path(1)).to eq("/posts/1/preview")
        expect(app.list_posts_path).to eq("/posts/list")
      end

      it "no parent resources block" do
        expect {
          router.draw do
            get "preview", on: :member
            get "list", on: :collection
          end
        }.to raise_error(Jets::Router::Error)
      end
    end

    context "namespace" do
      it "admin resources posts" do
        captured_scope = nil
        router.draw do
          namespace :admin do
            resources :posts
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-----------------+--------+----------------------+--------------------+
|       As        |  Verb  |         Path         | Controller#action  |
+-----------------+--------+----------------------+--------------------+
| admin_posts     | GET    | admin/posts          | admin/posts#index  |
| new_admin_post  | GET    | admin/posts/new      | admin/posts#new    |
| admin_post      | GET    | admin/posts/:id      | admin/posts#show   |
|                 | POST   | admin/posts          | admin/posts#create |
| edit_admin_post | GET    | admin/posts/:id/edit | admin/posts#edit   |
|                 | PUT    | admin/posts/:id      | admin/posts#update |
|                 | POST   | admin/posts/:id      | admin/posts#update |
|                 | PATCH  | admin/posts/:id      | admin/posts#update |
|                 | DELETE | admin/posts/:id      | admin/posts#delete |
+-----------------+--------+----------------------+--------------------+
EOL
        expect(output).to eq(table)

        expect(app.admin_posts_path).to eq("/admin/posts")
        expect(app.new_admin_post_path).to eq("/admin/posts/new")
        expect(app.admin_post_path(1)).to eq("/admin/posts/1")
        expect(app.edit_admin_post_path(1)).to eq("/admin/posts/1/edit")
      end

      it "namespace v1 namespace admin resources posts resources comments multiple lines" do
        router.draw do
          namespace :v1 do
            namespace :admin do
              resources :posts do
                resources :comments
              end
            end
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+----------------------------+--------+-------------------------------------------+--------------------------+
|             As             |  Verb  |                   Path                    |    Controller#action     |
+----------------------------+--------+-------------------------------------------+--------------------------+
| v1_admin_posts             | GET    | v1/admin/posts                            | v1/admin/posts#index     |
| new_v1_admin_post          | GET    | v1/admin/posts/new                        | v1/admin/posts#new       |
| v1_admin_post              | GET    | v1/admin/posts/:post_id                   | v1/admin/posts#show      |
|                            | POST   | v1/admin/posts                            | v1/admin/posts#create    |
| edit_v1_admin_post         | GET    | v1/admin/posts/:post_id/edit              | v1/admin/posts#edit      |
|                            | PUT    | v1/admin/posts/:post_id                   | v1/admin/posts#update    |
|                            | POST   | v1/admin/posts/:post_id                   | v1/admin/posts#update    |
|                            | PATCH  | v1/admin/posts/:post_id                   | v1/admin/posts#update    |
|                            | DELETE | v1/admin/posts/:post_id                   | v1/admin/posts#delete    |
| v1_admin_post_comments     | GET    | v1/admin/posts/:post_id/comments          | v1/admin/comments#index  |
| new_v1_admin_post_comment  | GET    | v1/admin/posts/:post_id/comments/new      | v1/admin/comments#new    |
| v1_admin_post_comment      | GET    | v1/admin/posts/:post_id/comments/:id      | v1/admin/comments#show   |
|                            | POST   | v1/admin/posts/:post_id/comments          | v1/admin/comments#create |
| edit_v1_admin_post_comment | GET    | v1/admin/posts/:post_id/comments/:id/edit | v1/admin/comments#edit   |
|                            | PUT    | v1/admin/posts/:post_id/comments/:id      | v1/admin/comments#update |
|                            | POST   | v1/admin/posts/:post_id/comments/:id      | v1/admin/comments#update |
|                            | PATCH  | v1/admin/posts/:post_id/comments/:id      | v1/admin/comments#update |
|                            | DELETE | v1/admin/posts/:post_id/comments/:id      | v1/admin/comments#delete |
+----------------------------+--------+-------------------------------------------+--------------------------+
EOL
        expect(output).to eq(table)

        expect(app.v1_admin_posts_path).to eq("/v1/admin/posts")
        expect(app.new_v1_admin_post_path).to eq("/v1/admin/posts/new")
        expect(app.v1_admin_post_path(1)).to eq("/v1/admin/posts/1")
        expect(app.edit_v1_admin_post_path(1)).to eq("/v1/admin/posts/1/edit")

        expect(app.v1_admin_post_comments_path(1)).to eq("/v1/admin/posts/1/comments")
        expect(app.new_v1_admin_post_comment_path(1)).to eq("/v1/admin/posts/1/comments/new")
        expect(app.v1_admin_post_comment_path(1,2)).to eq("/v1/admin/posts/1/comments/2")
        expect(app.edit_v1_admin_post_comment_path(1,2)).to eq("/v1/admin/posts/1/comments/2/edit")
      end

      it "namespace v1/admin resources posts resources comments" do
        router.draw do
          namespace "v1/admin" do
            resources :posts do
              resources :comments
            end
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+----------------------------+--------+-------------------------------------------+--------------------------+
|             As             |  Verb  |                   Path                    |    Controller#action     |
+----------------------------+--------+-------------------------------------------+--------------------------+
| v1_admin_posts             | GET    | v1/admin/posts                            | v1/admin/posts#index     |
| new_v1_admin_post          | GET    | v1/admin/posts/new                        | v1/admin/posts#new       |
| v1_admin_post              | GET    | v1/admin/posts/:post_id                   | v1/admin/posts#show      |
|                            | POST   | v1/admin/posts                            | v1/admin/posts#create    |
| edit_v1_admin_post         | GET    | v1/admin/posts/:post_id/edit              | v1/admin/posts#edit      |
|                            | PUT    | v1/admin/posts/:post_id                   | v1/admin/posts#update    |
|                            | POST   | v1/admin/posts/:post_id                   | v1/admin/posts#update    |
|                            | PATCH  | v1/admin/posts/:post_id                   | v1/admin/posts#update    |
|                            | DELETE | v1/admin/posts/:post_id                   | v1/admin/posts#delete    |
| v1_admin_post_comments     | GET    | v1/admin/posts/:post_id/comments          | v1/admin/comments#index  |
| new_v1_admin_post_comment  | GET    | v1/admin/posts/:post_id/comments/new      | v1/admin/comments#new    |
| v1_admin_post_comment      | GET    | v1/admin/posts/:post_id/comments/:id      | v1/admin/comments#show   |
|                            | POST   | v1/admin/posts/:post_id/comments          | v1/admin/comments#create |
| edit_v1_admin_post_comment | GET    | v1/admin/posts/:post_id/comments/:id/edit | v1/admin/comments#edit   |
|                            | PUT    | v1/admin/posts/:post_id/comments/:id      | v1/admin/comments#update |
|                            | POST   | v1/admin/posts/:post_id/comments/:id      | v1/admin/comments#update |
|                            | PATCH  | v1/admin/posts/:post_id/comments/:id      | v1/admin/comments#update |
|                            | DELETE | v1/admin/posts/:post_id/comments/:id      | v1/admin/comments#delete |
+----------------------------+--------+-------------------------------------------+--------------------------+
EOL
        expect(output).to eq(table)

        expect(app.v1_admin_posts_path).to eq("/v1/admin/posts")
        expect(app.new_v1_admin_post_path).to eq("/v1/admin/posts/new")
        expect(app.v1_admin_post_path(1)).to eq("/v1/admin/posts/1")
        expect(app.edit_v1_admin_post_path(1)).to eq("/v1/admin/posts/1/edit")

        expect(app.v1_admin_post_comments_path(1)).to eq("/v1/admin/posts/1/comments")
        expect(app.new_v1_admin_post_comment_path(1)).to eq("/v1/admin/posts/1/comments/new")
        expect(app.v1_admin_post_comment_path(1,2)).to eq("/v1/admin/posts/1/comments/2")
        expect(app.edit_v1_admin_post_comment_path(1,2)).to eq("/v1/admin/posts/1/comments/2/edit")
      end

      it "regular create route methods" do
        router.draw do
          namespace "admin" do
            get "posts", to: "posts#index"
            get "posts/:id", to: "posts#show"
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------------+------+-----------------+-------------------+
|     As      | Verb |      Path       | Controller#action |
+-------------+------+-----------------+-------------------+
| admin_posts | GET  | admin/posts     | admin/posts#index |
| admin_post  | GET  | admin/posts/:id | admin/posts#show  |
+-------------+------+-----------------+-------------------+
EOL
        expect(output).to eq(table)

        expect(app.admin_posts_path).to eq("/admin/posts")
        expect(app.admin_post_path(1)).to eq("/admin/posts/1")
      end
    end

    context "prefix" do
      it "admin resources posts" do
        router.draw do
          prefix :admin do
            resources :posts
          end
        end
        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-----------+--------+----------------------+-------------------+
|    As     |  Verb  |         Path         | Controller#action |
+-----------+--------+----------------------+-------------------+
| posts     | GET    | admin/posts          | posts#index       |
| new_post  | GET    | admin/posts/new      | posts#new         |
| post      | GET    | admin/posts/:id      | posts#show        |
|           | POST   | admin/posts          | posts#create      |
| edit_post | GET    | admin/posts/:id/edit | posts#edit        |
|           | PUT    | admin/posts/:id      | posts#update      |
|           | POST   | admin/posts/:id      | posts#update      |
|           | PATCH  | admin/posts/:id      | posts#update      |
|           | DELETE | admin/posts/:id      | posts#delete      |
+-----------+--------+----------------------+-------------------+
EOL
        expect(output).to eq(table)

        expect(app.posts_path).to eq("/admin/posts")
        expect(app.new_post_path).to eq("/admin/posts/new")
        expect(app.post_path(1)).to eq("/admin/posts/1")
        expect(app.edit_post_path(1)).to eq("/admin/posts/1/edit")
      end
    end

    context "scope with prefix" do
      it "single admin prefix" do
        router.draw do
          scope(prefix: :admin) do
            get "posts", to: "posts#index"
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------+------+-------------+-------------------+
|  As   | Verb |    Path     | Controller#action |
+-------+------+-------------+-------------------+
| posts | GET  | admin/posts | posts#index       |
+-------+------+-------------+-------------------+
EOL
        expect(output).to eq(table)
      end

      it "nested admin prefix on multiple lines" do
        router.draw do
          scope(prefix: :v1) do
            scope(prefix: :admin) do
              get "posts", to: "posts#index"
            end
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------+------+----------------+-------------------+
|  As   | Verb |      Path      | Controller#action |
+-------+------+----------------+-------------------+
| posts | GET  | v1/admin/posts | posts#index       |
+-------+------+----------------+-------------------+
EOL
        expect(output).to eq(table)
      end

      it "nested admin prefix on oneline" do
        router.draw do
          scope(prefix: :v1) do
            scope(prefix: :admin) do
              get "posts", to: "posts#index"
            end
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------+------+----------------+-------------------+
|  As   | Verb |      Path      | Controller#action |
+-------+------+----------------+-------------------+
| posts | GET  | v1/admin/posts | posts#index       |
+-------+------+----------------+-------------------+
EOL
        expect(output).to eq(table)
      end

      it "nested admin prefix as string" do
        router.draw do
          scope "v1/admin" do
            get "posts", to: "posts#index"
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------+------+----------------+-------------------+
|  As   | Verb |      Path      | Controller#action |
+-------+------+----------------+-------------------+
| posts | GET  | v1/admin/posts | posts#index       |
+-------+------+----------------+-------------------+
EOL
        expect(output).to eq(table)
      end

      it "nested admin prefix as symbol" do
        router.draw do
          scope :admin do
            get "posts", to: "posts#index"
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------+------+-------------+-------------------+
|  As   | Verb |    Path     | Controller#action |
+-------+------+-------------+-------------------+
| posts | GET  | admin/posts | posts#index       |
+-------+------+-------------+-------------------+
EOL
        expect(output).to eq(table)
      end
    end

    context "scope with as" do
      it "single admin as with individual routes" do
        router.draw do
          scope(as: :admin) do
            get "posts", to: "posts#index"
            get "posts/new", to: "posts#new"
            get "posts/:id", to: "posts#show"
            post "posts", to: "posts#create"
            get "posts/:id/edit", to: "posts#edit"
            put "posts/:id", to: "posts#update"
            post "posts/:id", to: "posts#update"
            patch "posts/:id", to: "posts#update"
            delete "posts/:id", to: "posts#delete"
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-----------------+--------+----------------+-------------------+
|       As        |  Verb  |      Path      | Controller#action |
+-----------------+--------+----------------+-------------------+
| admin_posts     | GET    | posts          | posts#index       |
| new_admin_post  | GET    | posts/new      | posts#new         |
| admin_post      | GET    | posts/:id      | posts#show        |
|                 | POST   | posts          | posts#create      |
| edit_admin_post | GET    | posts/:id/edit | posts#edit        |
|                 | PUT    | posts/:id      | posts#update      |
|                 | POST   | posts/:id      | posts#update      |
|                 | PATCH  | posts/:id      | posts#update      |
|                 | DELETE | posts/:id      | posts#delete      |
+-----------------+--------+----------------+-------------------+
EOL
        expect(output).to eq(table)
      end

      it "single admin as with resources" do
        router.draw do
          scope(as: :admin) do
            resources :posts
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-----------------+--------+----------------+-------------------+
|       As        |  Verb  |      Path      | Controller#action |
+-----------------+--------+----------------+-------------------+
| admin_posts     | GET    | posts          | posts#index       |
| new_admin_post  | GET    | posts/new      | posts#new         |
| admin_post      | GET    | posts/:id      | posts#show        |
|                 | POST   | posts          | posts#create      |
| edit_admin_post | GET    | posts/:id/edit | posts#edit        |
|                 | PUT    | posts/:id      | posts#update      |
|                 | POST   | posts/:id      | posts#update      |
|                 | PATCH  | posts/:id      | posts#update      |
|                 | DELETE | posts/:id      | posts#delete      |
+-----------------+--------+----------------+-------------------+
EOL
        expect(output).to eq(table)
      end
    end

    context "scope with module" do
      # more general scope method
      it "admin module single method" do
        router.draw do
          scope(module: :admin) do
            get "posts", to: "posts#index"
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------+------+-------+-------------------+
|  As   | Verb | Path  | Controller#action |
+-------+------+-------+-------------------+
| posts | GET  | posts | admin/posts#index |
+-------+------+-------+-------------------+
EOL
        expect(output).to eq(table)
      end

      it "admin module all methods" do
        router.draw do
          scope(module: :admin) do
            resources "posts"
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-----------+--------+----------------+--------------------+
|    As     |  Verb  |      Path      | Controller#action  |
+-----------+--------+----------------+--------------------+
| posts     | GET    | posts          | admin/posts#index  |
| new_post  | GET    | posts/new      | admin/posts#new    |
| post      | GET    | posts/:id      | admin/posts#show   |
|           | POST   | posts          | admin/posts#create |
| edit_post | GET    | posts/:id/edit | admin/posts#edit   |
|           | PUT    | posts/:id      | admin/posts#update |
|           | POST   | posts/:id      | admin/posts#update |
|           | PATCH  | posts/:id      | admin/posts#update |
|           | DELETE | posts/:id      | admin/posts#delete |
+-----------+--------+----------------+--------------------+
EOL
        expect(output).to eq(table)

        expect(app.posts_path).to eq("/posts")
        expect(app.new_post_path).to eq("/posts/new")
        expect(app.post_path(1)).to eq("/posts/1")
        expect(app.edit_post_path(1)).to eq("/posts/1/edit")
      end

      it "api/v1 module nested single method" do
        router.draw do
          scope(module: :api) do
            scope(module: :v1) do
              get "posts", to: "posts#index"
            end
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------+------+-------+--------------------+
|  As   | Verb | Path  | Controller#action  |
+-------+------+-------+--------------------+
| posts | GET  | posts | api/v1/posts#index |
+-------+------+-------+--------------------+
EOL
        expect(output).to eq(table)
      end

      it "api/v1 module nested all resources methods" do
        router.draw do
          scope(module: :api) do
            scope(module: :v1) do
              resources :posts
            end
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-----------+--------+----------------+---------------------+
|    As     |  Verb  |      Path      |  Controller#action  |
+-----------+--------+----------------+---------------------+
| posts     | GET    | posts          | api/v1/posts#index  |
| new_post  | GET    | posts/new      | api/v1/posts#new    |
| post      | GET    | posts/:id      | api/v1/posts#show   |
|           | POST   | posts          | api/v1/posts#create |
| edit_post | GET    | posts/:id/edit | api/v1/posts#edit   |
|           | PUT    | posts/:id      | api/v1/posts#update |
|           | POST   | posts/:id      | api/v1/posts#update |
|           | PATCH  | posts/:id      | api/v1/posts#update |
|           | DELETE | posts/:id      | api/v1/posts#delete |
+-----------+--------+----------------+---------------------+
EOL
        expect(output).to eq(table)

        expect(app.posts_path).to eq("/posts")
        expect(app.new_post_path).to eq("/posts/new")
        expect(app.post_path(1)).to eq("/posts/1")
        expect(app.edit_post_path(1)).to eq("/posts/1/edit")
      end

      it "api/v1 module oneline" do
        router.draw do
          scope(module: "api/v1") do
            get "posts", to: "posts#index"
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------+------+-------+--------------------+
|  As   | Verb | Path  | Controller#action  |
+-------+------+-------+--------------------+
| posts | GET  | posts | api/v1/posts#index |
+-------+------+-------+--------------------+
EOL
        expect(output).to eq(table)
      end

      it "get posts resources" do
        router.draw do
          resources :posts
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-----------+--------+----------------+-------------------+
|    As     |  Verb  |      Path      | Controller#action |
+-----------+--------+----------------+-------------------+
| posts     | GET    | posts          | posts#index       |
| new_post  | GET    | posts/new      | posts#new         |
| post      | GET    | posts/:id      | posts#show        |
|           | POST   | posts          | posts#create      |
| edit_post | GET    | posts/:id/edit | posts#edit        |
|           | PUT    | posts/:id      | posts#update      |
|           | POST   | posts/:id      | posts#update      |
|           | PATCH  | posts/:id      | posts#update      |
|           | DELETE | posts/:id      | posts#delete      |
+-----------+--------+----------------+-------------------+
EOL
        expect(output).to eq(table)
      end

      it "get posts create_route methods" do
        router.draw do
          get "posts", to: "posts#index"
          get "posts/new", to: "posts#new"
          get "posts/:id", to: "posts#show"
          post "posts", to: "posts#create"
          get "posts/:id/edit", to: "posts#edit"
          put "posts/:id", to: "posts#update"
          post "posts/:id", to: "posts#update"
          patch "posts/:id", to: "posts#update"
          delete "posts/:id", to: "posts#delete"
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-----------+--------+----------------+-------------------+
|    As     |  Verb  |      Path      | Controller#action |
+-----------+--------+----------------+-------------------+
| posts     | GET    | posts          | posts#index       |
| new_post  | GET    | posts/new      | posts#new         |
| post      | GET    | posts/:id      | posts#show        |
|           | POST   | posts          | posts#create      |
| edit_post | GET    | posts/:id/edit | posts#edit        |
|           | PUT    | posts/:id      | posts#update      |
|           | POST   | posts/:id      | posts#update      |
|           | PATCH  | posts/:id      | posts#update      |
|           | DELETE | posts/:id      | posts#delete      |
+-----------+--------+----------------+-------------------+
EOL
        expect(output).to eq(table)

        expect(app.posts_path).to eq("/posts")
        expect(app.new_post_path).to eq("/posts/new")
        expect(app.post_path(1)).to eq("/posts/1")
        expect(app.edit_post_path(1)).to eq("/posts/1/edit")
      end

      # prettier namespace method
      it "api/v2 namespace" do
        router.draw do
          namespace "api/v2" do
            get "posts", to: "posts#index"
          end
        end
        route = router.routes.first
        expect(route.path).to eq "api/v2/posts"
      end
    end

    context "standalone routes" do
      it "various" do
        router.draw do
          any "comments/hot", to: "comments#hot"
          get "landing/foo/bar", to: "posts#index"
          get "admin/pages", to: "admin/pages#index"
          get "related_posts/:id", to: "related_posts#show"
          any "others/*proxy", to: "others#catchall"
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+--------------+------+-------------------+--------------------+
|      As      | Verb |       Path        | Controller#action  |
+--------------+------+-------------------+--------------------+
|              | ANY  | comments/hot      | comments#hot       |
| posts        | GET  | landing/foo/bar   | posts#index        |
| admin_pages  | GET  | admin/pages       | admin/pages#index  |
| related_post | GET  | related_posts/:id | related_posts#show |
|              | ANY  | others/*proxy     | others#catchall    |
+--------------+------+-------------------+--------------------+
EOL
        # expect(output).to eq(table)
      end

      it "builds up routes in memory" do
        router.draw do
          resources :articles
          resources :posts
          any "comments/hot", to: "comments#hot"
          get "landing/posts", to: "posts#index"
          get "admin/pages", to: "admin/pages#index"
          get "related_posts/:id", to: "related_posts#show"
          any "others/*proxy", to: "others#catchall"
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+--------------+--------+-------------------+--------------------+
|      As      |  Verb  |       Path        | Controller#action  |
+--------------+--------+-------------------+--------------------+
| articles     | GET    | articles          | articles#index     |
| new_article  | GET    | articles/new      | articles#new       |
| article      | GET    | articles/:id      | articles#show      |
|              | POST   | articles          | articles#create    |
| edit_article | GET    | articles/:id/edit | articles#edit      |
|              | PUT    | articles/:id      | articles#update    |
|              | POST   | articles/:id      | articles#update    |
|              | PATCH  | articles/:id      | articles#update    |
|              | DELETE | articles/:id      | articles#delete    |
| posts        | GET    | posts             | posts#index        |
| new_post     | GET    | posts/new         | posts#new          |
| post         | GET    | posts/:id         | posts#show         |
|              | POST   | posts             | posts#create       |
| edit_post    | GET    | posts/:id/edit    | posts#edit         |
|              | PUT    | posts/:id         | posts#update       |
|              | POST   | posts/:id         | posts#update       |
|              | PATCH  | posts/:id         | posts#update       |
|              | DELETE | posts/:id         | posts#delete       |
|              | ANY    | comments/hot      | comments#hot       |
|              | GET    | landing/posts     | posts#index        |
|              | GET    | admin/pages       | admin/pages#index  |
| related_post | GET    | related_posts/:id | related_posts#show |
|              | ANY    | others/*proxy     | others#catchall    |
+--------------+--------+-------------------+--------------------+
EOL
        expect(output).to eq(table)
      end

      it "root" do
        router.draw do
          root "posts#index"
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+------+------+------+-------------------+
|  As  | Verb | Path | Controller#action |
+------+------+------+-------------------+
| root | GET  |      | posts#index       |
+------+------+------+-------------------+
EOL
        expect(output).to eq(table)

        route = router.routes.first
        expect(route).to be_a(Jets::Router::Route)
        expect(route.homepage?).to be true
        expect(route.to).to eq "posts#index"
        expect(route.path).to eq ''
        expect(route.method).to eq "GET"
      end
    end

    context "routes with resources macro" do
      it "expands macro to all the REST routes" do
        router.draw do
          resources :posts
        end
        tos = router.routes.map(&:to).sort.uniq
        expect(tos).to eq(
          ["posts#create", "posts#delete", "posts#edit", "posts#index", "posts#new", "posts#show", "posts#update"].sort
        )
      end

      it "all_paths list all subpaths" do
        router.draw do
          resources :posts
        end
        # pp router.routes # uncomment to debug
        expect(router.all_paths).to eq(
          ["posts", "posts/:id", "posts/:id/edit", "posts/new"]
        )
      end

      it "ordered_routes should sort by precedence" do
        router.draw do
          resources :posts
          any "*catchall", to: "catch#all"
        end
        paths = router.ordered_routes.map(&:path).uniq
        expect(paths).to eq(
          ["posts/new", "posts", "posts/:id/edit", "posts/:id", "*catchall"])
      end

      it "ordered_routes should sort nested resources new before show" do
        router.draw do
          resources :posts do
            resources :comments
          end
          any "*catchall", to: "catch#all"
        end
        paths = router.ordered_routes.map(&:path).uniq
        expect(paths.index("posts/:post_id/comments/new")).to be < paths.index("posts/:post_id/comments/:id")
      end
    end

    context "direct as" do
      it "logout" do
        router.draw do
          get "exit", to: "sessions#destroy", as: :logout
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+--------+------+------+-------------------+
|   As   | Verb | Path | Controller#action |
+--------+------+------+-------------------+
| logout | GET  | exit | sessions#destroy  |
+--------+------+------+-------------------+
EOL
        expect(output).to eq(table)

        expect(app.logout_path).to eq("/exit")
      end

      it "namespace logout" do
        router.draw do
          namespace :users do
            get "exit", to: "sessions#destroy", as: :logout
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+--------+------+------------+------------------------+
|   As   | Verb |    Path    |   Controller#action    |
+--------+------+------------+------------------------+
| logout | GET  | users/exit | users/sessions#destroy |
+--------+------+------------+------------------------+
EOL
        expect(output).to eq(table)

        expect(app.logout_path).to eq("/users/exit")
      end
    end

    context "regular create_route methods" do
      it "resources users posts" do
        router.draw do
          resources :users, only: [] do
            get "posts", to: "posts#index"
            get "posts/new", to: "posts#new"
            get "posts/:id", to: "posts#show"
            post "posts", to: "posts#create"
            get "posts/:id/edit", to: "posts#edit"
            put "posts/:id", to: "posts#update"
            post "posts/:id", to: "posts#update"
            patch "posts/:id", to: "posts#update"
            delete "posts/:id", to: "posts#delete"
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+----------------+--------+-------------------------------+-------------------+
|       As       |  Verb  |             Path              | Controller#action |
+----------------+--------+-------------------------------+-------------------+
| user_posts     | GET    | users/:user_id/posts          | posts#index       |
| new_user_post  | GET    | users/:user_id/posts/new      | posts#new         |
| user_post      | GET    | users/:user_id/posts/:id      | posts#show        |
|                | POST   | users/:user_id/posts          | posts#create      |
| edit_user_post | GET    | users/:user_id/posts/:id/edit | posts#edit        |
|                | PUT    | users/:user_id/posts/:id      | posts#update      |
|                | POST   | users/:user_id/posts/:id      | posts#update      |
|                | PATCH  | users/:user_id/posts/:id      | posts#update      |
|                | DELETE | users/:user_id/posts/:id      | posts#delete      |
+----------------+--------+-------------------------------+-------------------+
EOL
        expect(output).to eq(table)

        expect(app.user_posts_path(1)).to eq("/users/1/posts")
        expect(app.new_user_post_path(1)).to eq("/users/1/posts/new")
        expect(app.user_post_path(1, 2)).to eq("/users/1/posts/2")
        expect(app.edit_user_post_path(1, 2)).to eq("/users/1/posts/2/edit")
      end

      it "posts as articles" do
        router.draw do
          get "posts", to: "posts#index", as: "articles"
          get "posts", to: "posts#list", as: "articles2"
          get "posts/new", to: "posts#new", as: "new_article"
          get "posts/:id", to: "posts#show", as: "article"
          get "posts/:id/edit", to: "posts#edit", as: "edit_article"
          get "posts", to: "posts#no_as" # should not create route
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+--------------+------+----------------+-------------------+
|      As      | Verb |      Path      | Controller#action |
+--------------+------+----------------+-------------------+
| articles     | GET  | posts          | posts#index       |
| articles2    | GET  | posts          | posts#list        |
| new_article  | GET  | posts/new      | posts#new         |
| article      | GET  | posts/:id      | posts#show        |
| edit_article | GET  | posts/:id/edit | posts#edit        |
|              | GET  | posts          | posts#no_as       |
+--------------+------+----------------+-------------------+
EOL
        expect(output).to eq(table)

        expect(app.articles_path).to eq("/posts")
        expect(app.articles2_path).to eq("/posts")
        expect(app.new_article_path).to eq("/posts/new")
        expect(app.article_path(1)).to eq("/posts/1")
        expect(app.edit_article_path(1)).to eq("/posts/1/edit")
      end
    end

    context "singular resource nested with plural resources" do
      it "profile posts" do
        router.draw do
          resource :profile do
            resources :posts
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------------------+--------+------------------------+-------------------+
|        As         |  Verb  |          Path          | Controller#action |
+-------------------+--------+------------------------+-------------------+
| new_profile       | GET    | profile/new            | profiles#new      |
| profile           | GET    | profile                | profiles#show     |
|                   | POST   | profile                | profiles#create   |
| edit_profile      | GET    | profile/edit           | profiles#edit     |
|                   | PUT    | profile                | profiles#update   |
|                   | POST   | profile                | profiles#update   |
|                   | PATCH  | profile                | profiles#update   |
|                   | DELETE | profile                | profiles#delete   |
| profile_posts     | GET    | profile/posts          | posts#index       |
| new_profile_post  | GET    | profile/posts/new      | posts#new         |
| profile_post      | GET    | profile/posts/:id      | posts#show        |
|                   | POST   | profile/posts          | posts#create      |
| edit_profile_post | GET    | profile/posts/:id/edit | posts#edit        |
|                   | PUT    | profile/posts/:id      | posts#update      |
|                   | POST   | profile/posts/:id      | posts#update      |
|                   | PATCH  | profile/posts/:id      | posts#update      |
|                   | DELETE | profile/posts/:id      | posts#delete      |
+-------------------+--------+------------------------+-------------------+
EOL
        expect(output).to eq(table)

        expect(app.new_profile_path).to eq("/profile/new")
        expect(app.profile_path).to eq("/profile")
        expect(app.edit_profile_path).to eq("/profile/edit")

        expect(app.profile_posts_path).to eq("/profile/posts")
        expect(app.new_profile_post_path).to eq("/profile/posts/new")
        expect(app.profile_post_path(1)).to eq("/profile/posts/1")
        expect(app.edit_profile_post_path(1)).to eq("/profile/posts/1/edit")
      end

      it "posts profile" do
        router.draw do
          resources :posts do
            resource :profile
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------------------+--------+-----------------------------+-------------------+
|        As         |  Verb  |            Path             | Controller#action |
+-------------------+--------+-----------------------------+-------------------+
| posts             | GET    | posts                       | posts#index       |
| new_post          | GET    | posts/new                   | posts#new         |
| post              | GET    | posts/:post_id              | posts#show        |
|                   | POST   | posts                       | posts#create      |
| edit_post         | GET    | posts/:post_id/edit         | posts#edit        |
|                   | PUT    | posts/:post_id              | posts#update      |
|                   | POST   | posts/:post_id              | posts#update      |
|                   | PATCH  | posts/:post_id              | posts#update      |
|                   | DELETE | posts/:post_id              | posts#delete      |
| new_post_profile  | GET    | posts/:post_id/profile/new  | profiles#new      |
| post_profile      | GET    | posts/:post_id/profile      | profiles#show     |
|                   | POST   | posts/:post_id/profile      | profiles#create   |
| edit_post_profile | GET    | posts/:post_id/profile/edit | profiles#edit     |
|                   | PUT    | posts/:post_id/profile      | profiles#update   |
|                   | POST   | posts/:post_id/profile      | profiles#update   |
|                   | PATCH  | posts/:post_id/profile      | profiles#update   |
|                   | DELETE | posts/:post_id/profile      | profiles#delete   |
+-------------------+--------+-----------------------------+-------------------+
EOL
        expect(output).to eq(table)

        expect(app.posts_path).to eq("/posts")
        expect(app.new_post_path).to eq("/posts/new")
        expect(app.post_path(1)).to eq("/posts/1")
        expect(app.edit_post_path(1)).to eq("/posts/1/edit")

        expect(app.new_post_profile_path(1)).to eq("/posts/1/profile/new")
        expect(app.post_profile_path(1)).to eq("/posts/1/profile")
        expect(app.edit_post_profile_path(1)).to eq("/posts/1/profile/edit")
      end
    end

    context "infer to option" do
      it "credit cards" do
        router.draw do
          get "credit_cards/open"
          get "credit_cards/debit"
          get "credit_cards/credit"
          get "credit_cards/close"
        end
        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+----+------+---------------------+---------------------+
| As | Verb |        Path         |  Controller#action  |
+----+------+---------------------+---------------------+
|    | GET  | credit_cards/open   | credit_cards#open   |
|    | GET  | credit_cards/debit  | credit_cards#debit  |
|    | GET  | credit_cards/credit | credit_cards#credit |
|    | GET  | credit_cards/close  | credit_cards#close  |
+----+------+---------------------+---------------------+
EOL
        expect(output).to eq(table)
      end
    end

    # Its possible to capture the scope from the DSL. Still weird to create the method though.
    # Leaving this around as an example in case leads to a better way of doing it.
    context "example of captured scope" do
      it "namespace admin posts" do
        captured_scope = nil
        router.draw do
          namespace :admin do
            resources :posts, only: [] do
              captured_scope = @scope
            end
          end
        end

        options = {:to=>"posts#index", :path=>"posts", :method=>:get, from_scope: true}
        creator = Jets::Router::MethodCreator::Index.new(options, captured_scope, "posts")
        expect(creator.path_method).to eq(<<~EOL)
          def admin_posts_path
            "/admin/posts"
          end
        EOL
      end

      it "resources users posts" do
        captured_scope = nil
        router.draw do
          resources :users, only: [] do
            resources :posts, only: [] do
              captured_scope = @scope
            end
          end
        end

        options = {:to=>"posts#index", :path=>"posts", :method=>:get, from_scope: true}
        creator = Jets::Router::MethodCreator::Index.new(options, captured_scope, "posts")
        expect(creator.path_method).to eq(<<~'EOL')
          def user_posts_path(user_id)
            "/users/#{user_id.to_param}/posts"
          end
        EOL
      end
    end

    ########################
    # useful for debugging
    context "debugging" do
      it "debug2" do
        router.draw do
          resources :posts, controller: "articles"
        end
        output = Jets::Router.help(router.routes).to_s
        # puts output
        # expect(app.post_comments_path(1)).to eq("/posts/1/comments")
      end
    end
  end
end
