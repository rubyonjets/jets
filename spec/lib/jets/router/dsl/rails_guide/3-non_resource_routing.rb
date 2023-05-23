class RestrictedListConstraint
  def initialize
    @ips = [] # RestrictedList.retrieve_ips
  end

  def matches?(request)
    @ips.include?(request.remote_ip)
  end
end

describe Jets::Router do
  let(:route_set) { Jets.application.routes }
  let(:app)       { RouterTestApp.new }

  describe "Router Rails Guide" do
    it "Bound Parameters" do
      output = draw do
        # Note: ( ... ) not supported
        # get 'photos(/:id)', to: 'photos#display'
        get 'photos/:id', to: 'photos#display'
      end
      text = <<~EOL
      photos GET /photos/:id photos#display
      EOL
      expect(output).to eq(text)
    end

    it "Dynamic Segments" do
      output = draw do
        get 'photos/:id/:user_id', to: 'photos#show'
      end
      text = <<~EOL
      photo GET /photos/:id/:user_id photos#show
      EOL
      expect(output).to eq(text)
    end

    it "Static Segments" do
      output = draw do
        get 'photos/:id/with_user/:user_id', to: 'photos#show'
      end
      text = <<~EOL
      photo GET /photos/:id/with_user/:user_id photos#show
      EOL
      expect(output).to eq(text)
    end

    it "Defining Defaults http method options" do
      output = draw do
        get 'photos/:id', to: 'photos#show', defaults: { format: 'jpg' }
      end

      text = <<~EOL
      photo GET /photos/:id photos#show
      EOL
      expect(output).to eq(text)

      route = find_route("/photos/1")
      expect(route.resolved_defaults).to eq({:format=>'jpg'})
    end

    it "Defining Defaults block" do
      output = draw do
        defaults format: :json do
          resources :photos
        end
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

      route = find_route("/photos")
      expect(route.resolved_defaults).to eq({:format=>:json})
    end

    it "Naming Routes as option" do
      output = draw do
        get 'exit', to: 'sessions#destroy', as: :logout
      end
      text = <<~EOL
      logout GET /exit sessions#destroy
      EOL
      expect(output).to eq(text)
    end

    it "Naming Routes overriding method by defining first" do
      output = draw do
        get ':username', to: 'users#show', as: :user
        resources :users
      end
      text = <<~EOL
      user      GET    /:username      users#show
      users     GET    /users          users#index
      users     POST   /users          users#create
      new_user  GET    /users/new      users#new
      edit_user GET    /users/:id/edit users#edit
      user      GET    /users/:id      users#show
      user      PUT    /users/:id      users#update
      user      PATCH  /users/:id      users#update
      user      DELETE /users/:id      users#destroy
      EOL
      expect(output).to eq(text)
    end

    it "HTTP Verb Constraints via get post" do
      output = draw do
        match 'photos/:id', to: 'photos#show', via: [:get, :post]
      end
      text = <<~EOL
      photo GET  /photos/:id photos#show
      photo POST /photos/:id photos#show
      EOL
      expect(output).to eq(text)
    end

    it "HTTP Verb Constraints via all" do
      output = draw do
        match 'photos', to: 'photos#show', via: :all
      end
      text = <<~EOL
      ANY /photos photos#show
      EOL
      expect(output).to eq(text)
    end

    it "Segment Constraints" do
      output = draw do
        get 'photos/:id', to: 'photos#show', constraints: { id: /[A-Z]\d{5}/ }
      end
      text = <<~EOL
      photo GET /photos/:id photos#show
      EOL
      expect(output).to eq(text)

      route = find_route("/photos/1")
      expect(route.constraints).to eq({ id: /[A-Z]\d{5}/ })
    end

    it "Segment Constraints id" do
      output = draw do
        get 'photos/:id', to: 'photos#show', id: /[A-Z]\d{5}/
      end
      text = <<~EOL
      photo GET /photos/:id photos#show
      EOL
      expect(output).to eq(text)

      route = find_route("/photos/1")
      expect(route.constraints).to eq({ id: /[A-Z]\d{5}/ })
    end

    it "Request-Based Constraints subdomain" do
      output = draw do
        get 'photos/:id', to: 'photos#show', constraints: { subdomain: 'admin' }
      end
      text = <<~EOL
      photo GET /photos/:id photos#show
      EOL
      expect(output).to eq(text)

      route = find_route("/photos/1")
      expect(route.constraints).to eq({ subdomain: 'admin' })
    end

    it "Request-Based Constraints block form" do
      output = draw do
        namespace :admin do
          constraints subdomain: 'admin' do
            resources :photos
          end
        end
      end
      text = <<~EOL
      admin_photos     GET    /admin/photos          admin/photos#index
      admin_photos     POST   /admin/photos          admin/photos#create
      new_admin_photo  GET    /admin/photos/new      admin/photos#new
      edit_admin_photo GET    /admin/photos/:id/edit admin/photos#edit
      admin_photo      GET    /admin/photos/:id      admin/photos#show
      admin_photo      PUT    /admin/photos/:id      admin/photos#update
      admin_photo      PATCH  /admin/photos/:id      admin/photos#update
      admin_photo      DELETE /admin/photos/:id      admin/photos#destroy
      EOL
      expect(output).to eq(text)

      route = find_route("/admin/photos")
      expect(route.constraints).to eq({ subdomain: 'admin' })
    end

    it "Advanced Constraints object that responds to matches" do
      output = draw do
        get '*path', to: 'restricted_list#index', constraints: RestrictedListConstraint.new
      end
      text = <<~EOL
      GET /*path restricted_list#index
      EOL
      expect(output).to eq(text)

      route = find_route("/photos/1")
      expect(route.constraints).to be_a(RestrictedListConstraint)
    end

    it "Advanced Constraints lambda" do
      output = draw do
        get '*path', to: 'restricted_list#index', constraints: lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }
      end
      text = <<~EOL
      GET /*path restricted_list#index
      EOL
      expect(output).to eq(text)

      route = find_route("/photos/1")
      expect(route.constraints).to be_a(Proc)
    end

    it "Route Globbing and Wildcard Segments" do
      output = draw do
        get 'photos/*other', to: 'photos#unknown'
      end
      text = <<~EOL
      GET /photos/*other photos#unknown
      EOL
      expect(output).to eq(text)
    end

    it "Route Globbing and Wildcard Segments anywhere" do
      output = draw do
        get 'books/*section/:title', to: 'books#show'
      end
      text = <<~EOL
      GET /books/*section/:title books#show
      EOL
      expect(output).to eq(text)
    end

    # Note: Unsure if this works for APIGW though
    it "Route Globbing and Wildcard Segments more than one wildcard" do
      output = draw do
        get '*a/foo/*b', to: 'test#index'
      end
      text = <<~EOL
      GET /*a/foo/*b test#index
      EOL
      expect(output).to eq(text)
    end

    # TODOs
    # 3.12 Redirection
    # 3.13 Routing to Rack Applications

    it "Using root" do
      output = draw do
        root to: 'pages#main'
      end
      text = <<~EOL
      root GET / pages#main
      EOL
      expect(output).to eq(text)

      route_set.clear!
      output = draw do
        root 'pages#main'
      end
      expect(output).to eq(text)

      expect(app.root_path).to eq("/")
    end

    it "Unicode Character Routes" do
      output = draw do
        get '/こんにちは', to: 'welcome#index'
      end
      text = <<~EOL
      GET /こんにちは welcome#index
      EOL
      expect(output).to eq(text)
    end

    # TODOs
    # 3.16 Direct Routes
    # 3.17 Using resolve

  end
end

