describe Jets::Router do
  let(:route_set) { Jets.application.routes }
  let(:app)       { RouterTestApp.new }

  describe "Router scope" do
    it "resources or option module" do
      output = draw do
        scope module: "api" do
          scope module: "v1" do
            resources :posts, only: [:edit], module: "draft"
          end
        end
      end
      text = <<~EOL
      edit_post GET /posts/:id/edit api/v1/draft/posts#edit
      EOL
      expect(output).to eq(text)

      route_set.clear!
      output = draw do
        scope module: "api" do
          scope module: "v1" do
            get "posts/:id/edit", to: "posts#edit", module: "draft"
          end
        end
      end
      expect(output).to eq(text)
    end
  end
end
