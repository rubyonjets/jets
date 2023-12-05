describe Jets::Router do
  let(:route_set) { Jets.application.routes }
  let(:app)       { RouterTestApp.new }

  describe "Router Rails Guide" do
    it "CRUD, Verbs, and Actions" do
      output = draw do
        resources :photos
      end
      text = <<~EOL
      photos     GET    /photos          photos#index
      photos     POST   /photos          photos#create
      new_photo  GET    /photos/new      photos#new
      edit_photo GET    /photos/:id/edit photos#edit
      photo      GET    /photos/:id      photos#show
      photo      PUT    /photos/:id      photos#update
      photo      PATCH  /photos/:id      photos#update
      photo      DELETE /photos/:id      photos#destroy
      EOL
      expect(output).to eq(text)
    end

    it "Defining Multiple Resources at the Same Time" do
      output = draw do
        resources :photos, :books, :videos
      end
      text = <<~EOL
      photos     GET    /photos          photos#index
      photos     POST   /photos          photos#create
      new_photo  GET    /photos/new      photos#new
      edit_photo GET    /photos/:id/edit photos#edit
      photo      GET    /photos/:id      photos#show
      photo      PUT    /photos/:id      photos#update
      photo      PATCH  /photos/:id      photos#update
      photo      DELETE /photos/:id      photos#destroy
      books      GET    /books           books#index
      books      POST   /books           books#create
      new_book   GET    /books/new       books#new
      edit_book  GET    /books/:id/edit  books#edit
      book       GET    /books/:id       books#show
      book       PUT    /books/:id       books#update
      book       PATCH  /books/:id       books#update
      book       DELETE /books/:id       books#destroy
      videos     GET    /videos          videos#index
      videos     POST   /videos          videos#create
      new_video  GET    /videos/new      videos#new
      edit_video GET    /videos/:id/edit videos#edit
      video      GET    /videos/:id      videos#show
      video      PUT    /videos/:id      videos#update
      video      PATCH  /videos/:id      videos#update
      video      DELETE /videos/:id      videos#destroy
      EOL
      expect(output).to eq(text)

      route_set.clear!
      output = draw do
        resources :photos
        resources :books
        resources :videos
      end
      expect(output).to eq(text)
    end

    it "Singular Resources profile users show" do
      output = draw do
        get 'profile', to: 'users#show'
      end
      text = <<~EOL
      profile GET /profile users#show
      EOL
      expect(output).to eq(text)
    end

    it "Singular Resources profile controller users" do
      output = draw do
        get 'profile', action: :show, controller: 'users'
      end
      text = <<~EOL
      profile GET /profile users#show
      EOL
      expect(output).to eq(text)
    end

    it "Singular Resources geocoder" do
      output = draw do
        resource :geocoder
      end
      text = <<~EOL
      geocoder      POST   /geocoder      geocoders#create
      new_geocoder  GET    /geocoder/new  geocoders#new
      edit_geocoder GET    /geocoder/edit geocoders#edit
      geocoder      GET    /geocoder      geocoders#show
      geocoder      PUT    /geocoder      geocoders#update
      geocoder      PATCH  /geocoder      geocoders#update
      geocoder      DELETE /geocoder      geocoders#destroy
      EOL
      expect(output).to eq(text)
    end

    it "Controller Namespaces and Routing" do
      output = draw do
        namespace :admin do
          resources :articles, :comments
        end
      end
      text = <<~EOL
      admin_articles     GET    /admin/articles          admin/articles#index
      admin_articles     POST   /admin/articles          admin/articles#create
      new_admin_article  GET    /admin/articles/new      admin/articles#new
      edit_admin_article GET    /admin/articles/:id/edit admin/articles#edit
      admin_article      GET    /admin/articles/:id      admin/articles#show
      admin_article      PUT    /admin/articles/:id      admin/articles#update
      admin_article      PATCH  /admin/articles/:id      admin/articles#update
      admin_article      DELETE /admin/articles/:id      admin/articles#destroy
      admin_comments     GET    /admin/comments          admin/comments#index
      admin_comments     POST   /admin/comments          admin/comments#create
      new_admin_comment  GET    /admin/comments/new      admin/comments#new
      edit_admin_comment GET    /admin/comments/:id/edit admin/comments#edit
      admin_comment      GET    /admin/comments/:id      admin/comments#show
      admin_comment      PUT    /admin/comments/:id      admin/comments#update
      admin_comment      PATCH  /admin/comments/:id      admin/comments#update
      admin_comment      DELETE /admin/comments/:id      admin/comments#destroy
      EOL
      expect(output).to eq(text)
    end

    it "Controller Namespaces and Routing scope block" do
      output = draw do
        scope module: 'admin' do
          resources :articles, :comments
        end
      end
      text = <<~EOL
      articles     GET    /articles          admin/articles#index
      articles     POST   /articles          admin/articles#create
      new_article  GET    /articles/new      admin/articles#new
      edit_article GET    /articles/:id/edit admin/articles#edit
      article      GET    /articles/:id      admin/articles#show
      article      PUT    /articles/:id      admin/articles#update
      article      PATCH  /articles/:id      admin/articles#update
      article      DELETE /articles/:id      admin/articles#destroy
      comments     GET    /comments          admin/comments#index
      comments     POST   /comments          admin/comments#create
      new_comment  GET    /comments/new      admin/comments#new
      edit_comment GET    /comments/:id/edit admin/comments#edit
      comment      GET    /comments/:id      admin/comments#show
      comment      PUT    /comments/:id      admin/comments#update
      comment      PATCH  /comments/:id      admin/comments#update
      comment      DELETE /comments/:id      admin/comments#destroy
      EOL
      expect(output).to eq(text)

      route_set.clear!
      output = draw do
        resources :articles, module: 'admin'
        resources :comments, module: 'admin'
      end
      expect(output).to eq(text)
    end

    it "Controller Namespaces and Routing scope block with path" do
      output = draw do
        scope '/admin' do
          resources :articles, :comments
        end
      end
      text = <<~EOL
      articles     GET    /admin/articles          articles#index
      articles     POST   /admin/articles          articles#create
      new_article  GET    /admin/articles/new      articles#new
      edit_article GET    /admin/articles/:id/edit articles#edit
      article      GET    /admin/articles/:id      articles#show
      article      PUT    /admin/articles/:id      articles#update
      article      PATCH  /admin/articles/:id      articles#update
      article      DELETE /admin/articles/:id      articles#destroy
      comments     GET    /admin/comments          comments#index
      comments     POST   /admin/comments          comments#create
      new_comment  GET    /admin/comments/new      comments#new
      edit_comment GET    /admin/comments/:id/edit comments#edit
      comment      GET    /admin/comments/:id      comments#show
      comment      PUT    /admin/comments/:id      comments#update
      comment      PATCH  /admin/comments/:id      comments#update
      comment      DELETE /admin/comments/:id      comments#destroy
      EOL
      expect(output).to eq(text)

      route_set.clear!
      output = draw do
        resources :articles, path: '/admin/articles'
        resources :comments, path: '/admin/comments'
      end
      expect(output).to eq(text)
    end

    it "Nested Resources" do
      output = draw do
        resources :magazines do
          resources :ads
        end
      end
      text = <<~EOL
      magazines        GET    /magazines                           magazines#index
      magazines        POST   /magazines                           magazines#create
      new_magazine     GET    /magazines/new                       magazines#new
      edit_magazine    GET    /magazines/:id/edit                  magazines#edit
      magazine         GET    /magazines/:id                       magazines#show
      magazine         PUT    /magazines/:id                       magazines#update
      magazine         PATCH  /magazines/:id                       magazines#update
      magazine         DELETE /magazines/:id                       magazines#destroy
      magazine_ads     GET    /magazines/:magazine_id/ads          ads#index
      magazine_ads     POST   /magazines/:magazine_id/ads          ads#create
      new_magazine_ad  GET    /magazines/:magazine_id/ads/new      ads#new
      edit_magazine_ad GET    /magazines/:magazine_id/ads/:id/edit ads#edit
      magazine_ad      GET    /magazines/:magazine_id/ads/:id      ads#show
      magazine_ad      PUT    /magazines/:magazine_id/ads/:id      ads#update
      magazine_ad      PATCH  /magazines/:magazine_id/ads/:id      ads#update
      magazine_ad      DELETE /magazines/:magazine_id/ads/:id      ads#destroy
      EOL
      expect(output).to eq(text)
    end

    it "Nested Resources Limits to Nesting" do
      output = draw do
        resources :publishers do
          resources :magazines do
            resources :photos
          end
        end
      end
      text = <<~EOL
      publishers                    GET    /publishers                                                      publishers#index
      publishers                    POST   /publishers                                                      publishers#create
      new_publisher                 GET    /publishers/new                                                  publishers#new
      edit_publisher                GET    /publishers/:id/edit                                             publishers#edit
      publisher                     GET    /publishers/:id                                                  publishers#show
      publisher                     PUT    /publishers/:id                                                  publishers#update
      publisher                     PATCH  /publishers/:id                                                  publishers#update
      publisher                     DELETE /publishers/:id                                                  publishers#destroy
      publisher_magazines           GET    /publishers/:publisher_id/magazines                              magazines#index
      publisher_magazines           POST   /publishers/:publisher_id/magazines                              magazines#create
      new_publisher_magazine        GET    /publishers/:publisher_id/magazines/new                          magazines#new
      edit_publisher_magazine       GET    /publishers/:publisher_id/magazines/:id/edit                     magazines#edit
      publisher_magazine            GET    /publishers/:publisher_id/magazines/:id                          magazines#show
      publisher_magazine            PUT    /publishers/:publisher_id/magazines/:id                          magazines#update
      publisher_magazine            PATCH  /publishers/:publisher_id/magazines/:id                          magazines#update
      publisher_magazine            DELETE /publishers/:publisher_id/magazines/:id                          magazines#destroy
      publisher_magazine_photos     GET    /publishers/:publisher_id/magazines/:magazine_id/photos          photos#index
      publisher_magazine_photos     POST   /publishers/:publisher_id/magazines/:magazine_id/photos          photos#create
      new_publisher_magazine_photo  GET    /publishers/:publisher_id/magazines/:magazine_id/photos/new      photos#new
      edit_publisher_magazine_photo GET    /publishers/:publisher_id/magazines/:magazine_id/photos/:id/edit photos#edit
      publisher_magazine_photo      GET    /publishers/:publisher_id/magazines/:magazine_id/photos/:id      photos#show
      publisher_magazine_photo      PUT    /publishers/:publisher_id/magazines/:magazine_id/photos/:id      photos#update
      publisher_magazine_photo      PATCH  /publishers/:publisher_id/magazines/:magazine_id/photos/:id      photos#update
      publisher_magazine_photo      DELETE /publishers/:publisher_id/magazines/:magazine_id/photos/:id      photos#destroy
      EOL
      expect(output).to eq(text)
    end

    it "Shallow Nesting comments shallow true" do
      output = draw do
        resources :articles do
          resources :comments, shallow: true
        end
      end
      text = <<~EOL
      articles            GET    /articles                          articles#index
      articles            POST   /articles                          articles#create
      new_article         GET    /articles/new                      articles#new
      edit_article        GET    /articles/:id/edit                 articles#edit
      article             GET    /articles/:id                      articles#show
      article             PUT    /articles/:id                      articles#update
      article             PATCH  /articles/:id                      articles#update
      article             DELETE /articles/:id                      articles#destroy
      article_comments    GET    /articles/:article_id/comments     comments#index
      article_comments    POST   /articles/:article_id/comments     comments#create
      new_article_comment GET    /articles/:article_id/comments/new comments#new
      edit_comment        GET    /comments/:id/edit                 comments#edit
      comment             GET    /comments/:id                      comments#show
      comment             PUT    /comments/:id                      comments#update
      comment             PATCH  /comments/:id                      comments#update
      comment             DELETE /comments/:id                      comments#destroy
      EOL
      expect(output).to eq(text)
    end

    it "Shallow Nesting articles shallow true" do
      output = draw do
        resources :articles, shallow: true do
          resources :comments
          resources :quotes
          resources :drafts
        end
      end
      text = <<~EOL
      articles            GET    /articles                          articles#index
      articles            POST   /articles                          articles#create
      new_article         GET    /articles/new                      articles#new
      edit_article        GET    /articles/:id/edit                 articles#edit
      article             GET    /articles/:id                      articles#show
      article             PUT    /articles/:id                      articles#update
      article             PATCH  /articles/:id                      articles#update
      article             DELETE /articles/:id                      articles#destroy
      article_comments    GET    /articles/:article_id/comments     comments#index
      article_comments    POST   /articles/:article_id/comments     comments#create
      new_article_comment GET    /articles/:article_id/comments/new comments#new
      edit_comment        GET    /comments/:id/edit                 comments#edit
      comment             GET    /comments/:id                      comments#show
      comment             PUT    /comments/:id                      comments#update
      comment             PATCH  /comments/:id                      comments#update
      comment             DELETE /comments/:id                      comments#destroy
      article_quotes      GET    /articles/:article_id/quotes       quotes#index
      article_quotes      POST   /articles/:article_id/quotes       quotes#create
      new_article_quote   GET    /articles/:article_id/quotes/new   quotes#new
      edit_quote          GET    /quotes/:id/edit                   quotes#edit
      quote               GET    /quotes/:id                        quotes#show
      quote               PUT    /quotes/:id                        quotes#update
      quote               PATCH  /quotes/:id                        quotes#update
      quote               DELETE /quotes/:id                        quotes#destroy
      article_drafts      GET    /articles/:article_id/drafts       drafts#index
      article_drafts      POST   /articles/:article_id/drafts       drafts#create
      new_article_draft   GET    /articles/:article_id/drafts/new   drafts#new
      edit_draft          GET    /drafts/:id/edit                   drafts#edit
      draft               GET    /drafts/:id                        drafts#show
      draft               PUT    /drafts/:id                        drafts#update
      draft               PATCH  /drafts/:id                        drafts#update
      draft               DELETE /drafts/:id                        drafts#destroy
      EOL
      expect(output).to eq(text)
    end

    it "Shallow Nesting shallow block" do
      output = draw do
        shallow do
          resources :articles do
            resources :comments
            resources :quotes
            resources :drafts
          end
        end
      end
      text = <<~EOL
      articles            GET    /articles                          articles#index
      articles            POST   /articles                          articles#create
      new_article         GET    /articles/new                      articles#new
      edit_article        GET    /articles/:id/edit                 articles#edit
      article             GET    /articles/:id                      articles#show
      article             PUT    /articles/:id                      articles#update
      article             PATCH  /articles/:id                      articles#update
      article             DELETE /articles/:id                      articles#destroy
      article_comments    GET    /articles/:article_id/comments     comments#index
      article_comments    POST   /articles/:article_id/comments     comments#create
      new_article_comment GET    /articles/:article_id/comments/new comments#new
      edit_comment        GET    /comments/:id/edit                 comments#edit
      comment             GET    /comments/:id                      comments#show
      comment             PUT    /comments/:id                      comments#update
      comment             PATCH  /comments/:id                      comments#update
      comment             DELETE /comments/:id                      comments#destroy
      article_quotes      GET    /articles/:article_id/quotes       quotes#index
      article_quotes      POST   /articles/:article_id/quotes       quotes#create
      new_article_quote   GET    /articles/:article_id/quotes/new   quotes#new
      edit_quote          GET    /quotes/:id/edit                   quotes#edit
      quote               GET    /quotes/:id                        quotes#show
      quote               PUT    /quotes/:id                        quotes#update
      quote               PATCH  /quotes/:id                        quotes#update
      quote               DELETE /quotes/:id                        quotes#destroy
      article_drafts      GET    /articles/:article_id/drafts       drafts#index
      article_drafts      POST   /articles/:article_id/drafts       drafts#create
      new_article_draft   GET    /articles/:article_id/drafts/new   drafts#new
      edit_draft          GET    /drafts/:id/edit                   drafts#edit
      draft               GET    /drafts/:id                        drafts#show
      draft               PUT    /drafts/:id                        drafts#update
      draft               PATCH  /drafts/:id                        drafts#update
      draft               DELETE /drafts/:id                        drafts#destroy
      EOL
      expect(output).to eq(text)
    end

    # TODO: shallow_path support
    # it "Shallow Nesting shallow_path sekret" do
    #   output = draw do
    #     scope shallow_path: "sekret" do
    #       resources :articles do
    #         resources :comments, shallow: true
    #       end
    #     end
    #   end
    #   text = <<~EOL
    #   articles            GET    /articles                          articles#index
    #   articles            POST   /articles                          articles#create
    #   new_article         GET    /articles/new                      articles#new
    #   edit_article        GET    /articles/:id/edit                 articles#edit
    #   article             GET    /articles/:id                      articles#show
    #   article             PUT    /articles/:id                      articles#update
    #   article             PATCH  /articles/:id                      articles#update
    #   article             DELETE /articles/:id                      articles#destroy
    #   article_comments    GET    /articles/:article_id/comments     comments#index
    #   article_comments    POST   /articles/:article_id/comments     comments#create
    #   new_article_comment GET    /articles/:article_id/comments/new comments#new
    #   edit_comment        GET    /sekret/comments/:id/edit          comments#edit
    #   comment             GET    /sekret/comments/:id               comments#show
    #   comment             PUT    /sekret/comments/:id               comments#update
    #   comment             PATCH  /sekret/comments/:id               comments#update
    #   comment             DELETE /sekret/comments/:id               comments#destroy
    #   EOL
    #   expect(output).to eq(text)
    # end

    # it "Shallow Nesting shallow_path sekret resources articles" do
    #   output = draw do
    #     scope shallow_path: "sekret" do
    #       resources :articles, shallow: true do
    #         resources :comments
    #       end
    #     end
    #   end
    #   text = <<~EOL
    #   EOL
    #   expect(output).to eq(text)
    # end

    # TODOs
    # Routing Concerns
    # Creating Paths and URLs from Objects
    #   url_for([@magazine, @ad])
    #   Array notation: link_to 'Ad details', [@magazine, @ad]

    it "Adding More RESTful Actions Adding Member Routes" do
      output = draw do
        resources :photos do
          member do
            get 'preview'
          end
        end
      end
      text = <<~EOL
      photos        GET    /photos             photos#index
      photos        POST   /photos             photos#create
      new_photo     GET    /photos/new         photos#new
      edit_photo    GET    /photos/:id/edit    photos#edit
      photo         GET    /photos/:id         photos#show
      photo         PUT    /photos/:id         photos#update
      photo         PATCH  /photos/:id         photos#update
      photo         DELETE /photos/:id         photos#destroy
      preview_photo GET    /photos/:id/preview photos#preview
      EOL
      expect(output).to eq(text)

      route_set.clear!
      output = draw do
        resources :photos do
          get 'preview', on: :member
        end
      end

      expect(output).to eq(text)
    end

    it "Adding More RESTful Actions Adding Collection Routes" do
      output = draw do
        resources :photos do
          collection do
            get 'search'
          end
        end
      end
      text = <<~EOL
      photos        GET    /photos          photos#index
      photos        POST   /photos          photos#create
      new_photo     GET    /photos/new      photos#new
      edit_photo    GET    /photos/:id/edit photos#edit
      photo         GET    /photos/:id      photos#show
      photo         PUT    /photos/:id      photos#update
      photo         PATCH  /photos/:id      photos#update
      photo         DELETE /photos/:id      photos#destroy
      search_photos GET    /photos/search   photos#search
      EOL
      expect(output).to eq(text)

      route_set.clear!
      output = draw do
        resources :photos do
          get 'search', on: :collection
        end
      end
      expect(output).to eq(text)
    end

    it "Adding More RESTful Actions Adding Routes for Additional New Actions" do
      output = draw do
        resources :photos do
          get 'preview', on: :new
        end
      end
      text = <<~EOL
      photos     GET    /photos             photos#index
      photos     POST   /photos             photos#create
      new_photo  GET    /photos/new         photos#new
      edit_photo GET    /photos/:id/edit    photos#edit
      photo      GET    /photos/:id         photos#show
      photo      PUT    /photos/:id         photos#update
      photo      PATCH  /photos/:id         photos#update
      photo      DELETE /photos/:id         photos#destroy
      new_photo  GET    /photos/new/preview photos#new
      EOL
      expect(output).to eq(text)
    end
  end
end
