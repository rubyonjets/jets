describe Jets::Router do
  let(:route_set) { Jets.application.routes }
  let(:app)       { RouterTestApp.new }

  describe "Router resource" do
    it "profile" do
      output = draw do
        resource :profile
      end
      # There is no index route for the singular resource
      text = <<~EOL
      profile      POST   /profile      profiles#create
      new_profile  GET    /profile/new  profiles#new
      edit_profile GET    /profile/edit profiles#edit
      profile      GET    /profile      profiles#show
      profile      PUT    /profile      profiles#update
      profile      PATCH  /profile      profiles#update
      profile      DELETE /profile      profiles#destroy
      EOL
      expect(output).to eq(text)

      expect(app.new_profile_path).to eq("/profile/new")
      expect(app.profile_path).to eq("/profile")
      expect(app.edit_profile_path).to eq("/profile/edit")
    end

    it "nested resources profile" do
      output = draw do
        resources :users do
          resource :profile
        end
      end
      # There is no index route for the singular resource
      text = <<~EOL
      users             GET    /users                       users#index
      users             POST   /users                       users#create
      new_user          GET    /users/new                   users#new
      edit_user         GET    /users/:id/edit              users#edit
      user              GET    /users/:id                   users#show
      user              PUT    /users/:id                   users#update
      user              PATCH  /users/:id                   users#update
      user              DELETE /users/:id                   users#destroy
      user_profile      POST   /users/:user_id/profile      profiles#create
      new_user_profile  GET    /users/:user_id/profile/new  profiles#new
      edit_user_profile GET    /users/:user_id/profile/edit profiles#edit
      user_profile      GET    /users/:user_id/profile      profiles#show
      user_profile      PUT    /users/:user_id/profile      profiles#update
      user_profile      PATCH  /users/:user_id/profile      profiles#update
      user_profile      DELETE /users/:user_id/profile      profiles#destroy
      EOL
      expect(output).to eq(text)

      expect(app.users_path).to eq("/users")
      expect(app.new_user_path).to eq("/users/new")
      expect(app.user_path(1)).to eq("/users/1")
      expect(app.edit_user_path(1)).to eq("/users/1/edit")

      expect(app.new_user_profile_path(1)).to eq("/users/1/profile/new")
      expect(app.user_profile_path(1)).to eq("/users/1/profile")
      expect(app.edit_user_profile_path(1)).to eq("/users/1/profile/edit")
    end

    it "nested namespace profile" do
      output = draw do
        namespace :admin do
          resource :profile
        end
      end
      text = <<~EOL
      admin_profile      POST   /admin/profile      admin/profiles#create
      new_admin_profile  GET    /admin/profile/new  admin/profiles#new
      edit_admin_profile GET    /admin/profile/edit admin/profiles#edit
      admin_profile      GET    /admin/profile      admin/profiles#show
      admin_profile      PUT    /admin/profile      admin/profiles#update
      admin_profile      PATCH  /admin/profile      admin/profiles#update
      admin_profile      DELETE /admin/profile      admin/profiles#destroy
      EOL
      expect(output).to eq(text)

      expect(app.new_admin_profile_path).to eq("/admin/profile/new")
      expect(app.admin_profile_path).to eq("/admin/profile")
      expect(app.edit_admin_profile_path).to eq("/admin/profile/edit")
    end

    it "member and collection" do
      output = draw do
        resource :profile do
          get "photo", on: :member
          get "comments", on: :collection
        end
      end
      text = <<~EOL
      profile          POST   /profile          profiles#create
      new_profile      GET    /profile/new      profiles#new
      edit_profile     GET    /profile/edit     profiles#edit
      profile          GET    /profile          profiles#show
      profile          PUT    /profile          profiles#update
      profile          PATCH  /profile          profiles#update
      profile          DELETE /profile          profiles#destroy
      photo_profile    GET    /profile/photo    profiles#photo
      comments_profile GET    /profile/comments profiles#comments
      EOL
      expect(output).to eq(text)

      expect(app.new_profile_path).to eq("/profile/new")
      expect(app.profile_path).to eq("/profile")
      expect(app.edit_profile_path).to eq("/profile/edit")
      expect(app.photo_profile_path).to eq("/profile/photo")
      expect(app.comments_profile_path).to eq("/profile/comments")
    end

    it "as option" do
      output = draw do
        resource :profile, as: :account
      end
      text = <<~EOL
      account      POST   /profile      profiles#create
      new_account  GET    /profile/new  profiles#new
      edit_account GET    /profile/edit profiles#edit
      account      GET    /profile      profiles#show
      account      PUT    /profile      profiles#update
      account      PATCH  /profile      profiles#update
      account      DELETE /profile      profiles#destroy
      EOL
      expect(output).to eq(text)

      expect(app.new_account_path).to eq("/profile/new")
      expect(app.account_path).to eq("/profile")
      expect(app.edit_account_path).to eq("/profile/edit")
    end

    # Sanity check that empty Hash does break. In case try to use ruby syntax
    #   def resource(*resource_names, **options)
    # With that syntax, would need to double splat it: resource(:profile, **{})
    it "resource with empty options" do
      output = draw do
        resource(:profile, {})
      end
      text = <<~EOL
      profile      POST   /profile      profiles#create
      new_profile  GET    /profile/new  profiles#new
      edit_profile GET    /profile/edit profiles#edit
      profile      GET    /profile      profiles#show
      profile      PUT    /profile      profiles#update
      profile      PATCH  /profile      profiles#update
      profile      DELETE /profile      profiles#destroy
      EOL
      expect(output).to eq(text)
    end
  end
end
