describe Jets::Router do
  let(:route_set) { Jets.application.routes }
  let(:app)       { RouterTestApp.new }

  describe "Router Rails Guide" do
    it "Specifying a Controller to Use" do
      output = draw do
        resources :photos, controller: 'images'
      end
      text = <<~EOL
      photos     GET    /photos          images#index
      photos     POST   /photos          images#create
      new_photo  GET    /photos/new      images#new
      edit_photo GET    /photos/:id/edit images#edit
      photo      GET    /photos/:id      images#show
      photo      PUT    /photos/:id      images#update
      photo      PATCH  /photos/:id      images#update
      photo      DELETE /photos/:id      images#destroy
      EOL
      expect(output).to eq(text)
    end

    it "namespaced controllers" do
      output = draw do
        resources :user_permissions, controller: 'admin/user_permissions'
      end
      text = <<~EOL
      user_permissions     GET    /user_permissions          admin/user_permissions#index
      user_permissions     POST   /user_permissions          admin/user_permissions#create
      new_user_permission  GET    /user_permissions/new      admin/user_permissions#new
      edit_user_permission GET    /user_permissions/:id/edit admin/user_permissions#edit
      user_permission      GET    /user_permissions/:id      admin/user_permissions#show
      user_permission      PUT    /user_permissions/:id      admin/user_permissions#update
      user_permission      PATCH  /user_permissions/:id      admin/user_permissions#update
      user_permission      DELETE /user_permissions/:id      admin/user_permissions#destroy
      EOL
      expect(output).to eq(text)
    end

    it "Specifying Constraints" do
      output = draw do
        resources :photos, constraints: { id: /[A-Z][A-Z][0-9]+/ }
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

      route = find_route("/photos/1")
      expect(route.constraints).to eq({ id: /[A-Z][A-Z][0-9]+/ })
    end

    it "Overriding the Named Route Helpers" do
      output = draw do
        resources :photos, as: 'images'
      end
      text = <<~EOL
      images     GET    /photos          photos#index
      images     POST   /photos          photos#create
      new_image  GET    /photos/new      photos#new
      edit_image GET    /photos/:id/edit photos#edit
      image      GET    /photos/:id      photos#show
      image      PUT    /photos/:id      photos#update
      image      PATCH  /photos/:id      photos#update
      image      DELETE /photos/:id      photos#destroy
      EOL
      expect(output).to eq(text)
    end

    it "Overriding the new and edit Segments" do
      output = draw do
        resources :photos, path_names: { new: 'make', edit: 'change' }
      end
      text = <<~EOL
      photos     GET    /photos            photos#index
      photos     POST   /photos            photos#create
      new_photo  GET    /photos/make       photos#new
      edit_photo GET    /photos/:id/change photos#edit
      photo      GET    /photos/:id        photos#show
      photo      PUT    /photos/:id        photos#update
      photo      PATCH  /photos/:id        photos#update
      photo      DELETE /photos/:id        photos#destroy
      EOL
      expect(output).to eq(text)
    end

    it "Change path_names uniformily" do
      output = draw do
        scope path_names: { new: 'make' } do
          resources :posts
        end
      end
      text = <<~EOL
      posts     GET    /posts          posts#index
      posts     POST   /posts          posts#create
      new_post  GET    /posts/make     posts#new
      edit_post GET    /posts/:id/edit posts#edit
      post      GET    /posts/:id      posts#show
      post      PUT    /posts/:id      posts#update
      post      PATCH  /posts/:id      posts#update
      post      DELETE /posts/:id      posts#destroy
      EOL
      expect(output).to eq(text)
    end

    it "Prefixing the Named Route Helpers" do
      output = draw do
        scope 'admin' do
          resources :photos, as: 'admin_photos'
        end
        resources :photos
      end
      text = <<~EOL
      admin_photos     GET    /admin/photos          photos#index
      admin_photos     POST   /admin/photos          photos#create
      new_admin_photo  GET    /admin/photos/new      photos#new
      edit_admin_photo GET    /admin/photos/:id/edit photos#edit
      admin_photo      GET    /admin/photos/:id      photos#show
      admin_photo      PUT    /admin/photos/:id      photos#update
      admin_photo      PATCH  /admin/photos/:id      photos#update
      admin_photo      DELETE /admin/photos/:id      photos#destroy
      photos           GET    /photos                photos#index
      photos           POST   /photos                photos#create
      new_photo        GET    /photos/new            photos#new
      edit_photo       GET    /photos/:id/edit       photos#edit
      photo            GET    /photos/:id            photos#show
      photo            PUT    /photos/:id            photos#update
      photo            PATCH  /photos/:id            photos#update
      photo            DELETE /photos/:id            photos#destroy
      EOL
      expect(output).to eq(text)
    end

    it "Parametric Scopes" do
      output = draw do
        scope ':account_id', as: 'account', constraints: { account_id: /\d+/ } do
          resources :articles
        end
      end
      text = <<~EOL
      account_articles     GET    /:account_id/articles          articles#index
      account_articles     POST   /:account_id/articles          articles#create
      new_account_article  GET    /:account_id/articles/new      articles#new
      edit_account_article GET    /:account_id/articles/:id/edit articles#edit
      account_article      GET    /:account_id/articles/:id      articles#show
      account_article      PUT    /:account_id/articles/:id      articles#update
      account_article      PATCH  /:account_id/articles/:id      articles#update
      account_article      DELETE /:account_id/articles/:id      articles#destroy
      EOL
      expect(output).to eq(text)

      expect(app.account_articles_path(1)).to eq("/1/articles")
      expect(app.edit_account_article_path(1,2)).to eq("/1/articles/2/edit")
    end

    it "Restricting the Routes Created" do
      output = draw do
        resources :photos, only: [:index, :show]
      end
      text = <<~EOL
      photos GET /photos     photos#index
      photo  GET /photos/:id photos#show
      EOL
      expect(output).to eq(text)
    end

    it "Restricting the Routes Created except" do
      output = draw do
        resources :photos, except: :destroy
      end
      text = <<~EOL
      photos     GET   /photos          photos#index
      photos     POST  /photos          photos#create
      new_photo  GET   /photos/new      photos#new
      edit_photo GET   /photos/:id/edit photos#edit
      photo      GET   /photos/:id      photos#show
      photo      PUT   /photos/:id      photos#update
      photo      PATCH /photos/:id      photos#update
      EOL
      expect(output).to eq(text)
    end

    it "Translated Paths" do
      output = draw do
        scope(path_names: { new: 'neu', edit: 'bearbeiten' }) do
          resources :categories, path: 'kategorien'
        end
      end
      text = <<~EOL
      categories    GET    /kategorien                categories#index
      categories    POST   /kategorien                categories#create
      new_category  GET    /kategorien/neu            categories#new
      edit_category GET    /kategorien/:id/bearbeiten categories#edit
      category      GET    /kategorien/:id            categories#show
      category      PUT    /kategorien/:id            categories#update
      category      PATCH  /kategorien/:id            categories#update
      category      DELETE /kategorien/:id            categories#destroy
      EOL
      expect(output).to eq(text)
    end

    it "Overriding the Singular Form" do
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.irregular 'tooth', 'teeth'
      end
      output = draw do
        resources :teeth
      end
      text = <<~EOL
      teeth      GET    /teeth          teeth#index
      teeth      POST   /teeth          teeth#create
      new_tooth  GET    /teeth/new      teeth#new
      edit_tooth GET    /teeth/:id/edit teeth#edit
      tooth      GET    /teeth/:id      teeth#show
      tooth      PUT    /teeth/:id      teeth#update
      tooth      PATCH  /teeth/:id      teeth#update
      tooth      DELETE /teeth/:id      teeth#destroy
      EOL
      expect(output).to eq(text)
    end

    it "Using :as in Nested Resources" do
      output = draw do
        resources :magazines do
          resources :ads, as: 'periodical_ads'
        end
      end
      text = <<~EOL
      magazines                   GET    /magazines                           magazines#index
      magazines                   POST   /magazines                           magazines#create
      new_magazine                GET    /magazines/new                       magazines#new
      edit_magazine               GET    /magazines/:id/edit                  magazines#edit
      magazine                    GET    /magazines/:id                       magazines#show
      magazine                    PUT    /magazines/:id                       magazines#update
      magazine                    PATCH  /magazines/:id                       magazines#update
      magazine                    DELETE /magazines/:id                       magazines#destroy
      magazine_periodical_ads     GET    /magazines/:magazine_id/ads          ads#index
      magazine_periodical_ads     POST   /magazines/:magazine_id/ads          ads#create
      new_magazine_periodical_ad  GET    /magazines/:magazine_id/ads/new      ads#new
      edit_magazine_periodical_ad GET    /magazines/:magazine_id/ads/:id/edit ads#edit
      magazine_periodical_ad      GET    /magazines/:magazine_id/ads/:id      ads#show
      magazine_periodical_ad      PUT    /magazines/:magazine_id/ads/:id      ads#update
      magazine_periodical_ad      PATCH  /magazines/:magazine_id/ads/:id      ads#update
      magazine_periodical_ad      DELETE /magazines/:magazine_id/ads/:id      ads#destroy
      EOL
      expect(output).to eq(text)
    end

    it "Overriding Named Route Parameters" do
      output = draw do
        resources :videos, param: :identifier
      end
      text = <<~EOL
      videos     GET    /videos                  videos#index
      videos     POST   /videos                  videos#create
      new_video  GET    /videos/new              videos#new
      edit_video GET    /videos/:identifier/edit videos#edit
      video      GET    /videos/:identifier      videos#show
      video      PUT    /videos/:identifier      videos#update
      video      PATCH  /videos/:identifier      videos#update
      video      DELETE /videos/:identifier      videos#destroy
      EOL
      expect(output).to eq(text)
    end
  end
end

