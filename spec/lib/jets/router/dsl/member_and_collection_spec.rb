describe Jets::Router do
  let(:route_set) { Jets.application.routes }
  let(:app)       { RouterTestApp.new }

  describe "Router member and collection" do
    it "direct option" do
      output = draw do
        resources :posts, only: [] do
          get "preview", on: :member
          get "list", on: :collection
        end
      end
      text = <<~EOL
      preview_post GET /posts/:id/preview posts#preview
      list_posts   GET /posts/list        posts#list
      EOL
      expect(output).to eq(text)

      expect(app.preview_post_path(1)).to eq("/posts/1/preview")
      expect(app.list_posts_path).to eq("/posts/list")
    end

    it "nested resources member" do
      output = draw do
        resources :posts, only: [] do
          member do
            get "preview"
          end
          collection do
            get "list"
          end
        end
      end
      text = <<~EOL
      preview_post GET /posts/:id/preview posts#preview
      list_posts   GET /posts/list        posts#list
      EOL
      expect(output).to eq(text)

      expect(app.preview_post_path(1)).to eq("/posts/1/preview")
      expect(app.list_posts_path).to eq("/posts/list")
    end

    it "no parent resources block" do
      expect {
        output = draw do
          get "preview", on: :member
          get "list", on: :collection
        end
      }.to raise_error(Jets::Router::Error)
    end
  end
end