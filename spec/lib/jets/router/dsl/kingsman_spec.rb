describe Jets::Router do
  let(:route_set) { Jets.application.routes }
  let(:app)       { RouterTestApp.new }

  describe "Router" do
    it "match with as for new action" do
      output = draw do
        match "posts/:id/edit", as: "change", to: "posts#edit", via: [:get]
      end
      # A little annoying that as is change instead of change_post.
      # That's how Rails behaves though and it's tricky to get change_post right now.
      text = <<~EOL
      change GET /posts/:id/edit posts#edit
      EOL
      expect(output).to eq(text)
    end

    it "match with as" do
      output = draw do
        resource :session, only: [], controller: "kingsman/sessions", path: "" do
          match :destroy, path: "sign_out", as: "destroy", via: :delete
        end
      end
      text = <<~EOL
      destroy_session DELETE /sign_out kingsman/sessions#destroy
      EOL
      expect(output).to eq(text)
    end

    it "resource sessions" do
      output = draw do
        resource :session, only: [], controller: "kingsman/sessions", path: "" do
          get   :new,     path: "sign_in",  as: "new"
          post  :create,  path: "sign_in"
          match :destroy, path: "sign_out", as: "destroy", via: :delete
        end
      end
      text = <<~EOL
      new_session     GET    /sign_in  kingsman/sessions#new
      session         POST   /sign_in  kingsman/sessions#create
      destroy_session DELETE /sign_out kingsman/sessions#destroy
      EOL
      expect(output).to eq(text)
    end

    it "full scope with user sessions" do
      output = draw do
        scope(:as=>:user, :path=>"/users", :module=>nil) do
          resource :session, only: [], controller: "kingsman/sessions", path: "" do
            get   :new,     path: "sign_in",  as: "new"
            post  :create,  path: "sign_in"
            match :destroy, path: "sign_out", as: "destroy", via: :delete
          end
        end
      end
      text = <<~EOL
      new_user_session     GET    /users/sign_in  kingsman/sessions#new
      user_session         POST   /users/sign_in  kingsman/sessions#create
      destroy_user_session DELETE /users/sign_out kingsman/sessions#destroy
      EOL
      expect(output).to eq(text)
      # destroy_user_destroy_session DELETE users/sign_out kingsman/sessions#destroy
    end

    it "full scope with user registrations"  do
      output = draw do
        scope(as: :user, path: '/users') do
          resource(:registration,
                    only: [:new, :create, :edit, :update, :destroy],
                    path: "",
                    path_names: {new: "sign_up", edit: "edit", cancel: "cancel"},
                    controller: "kingsman/registrations") do
            get :cancel
          end
        end
      end
      text = <<~EOL
      user_registration        POST   /users         kingsman/registrations#create
      new_user_registration    GET    /users/sign_up kingsman/registrations#new
      edit_user_registration   GET    /users/edit    kingsman/registrations#edit
      user_registration        PUT    /users         kingsman/registrations#update
      user_registration        PATCH  /users         kingsman/registrations#update
      user_registration        DELETE /users         kingsman/registrations#destroy
      cancel_user_registration GET    /users/cancel  kingsman/registrations#cancel
      EOL
      expect(output).to eq(text)
    end
  end
end
