describe Jets::Router do
  let(:route_set) { Jets.application.routes }
  let(:app)       { RouterTestApp.new }

  # Demostrates that the Jets routing engine is close to the Rails routing engine.
  # Shows the slight differences, some due to APIGW and some due to Jets design decisions.
  describe "Router Rails Guide" do
    it "Connecting URLs to Code" do
      output = draw do
        get '/patients/:id', to: 'patients#show'
      end
      text = <<~EOL
      patient GET /patients/:id patients#show
      EOL
      expect(output).to eq(text)
    end

    it "Generating Paths and URLs from Code" do
      output = draw do
        get '/patients/:id', to: 'patients#show', as: 'patient'
      end
      text = <<~EOL
      patient GET /patients/:id patients#show
      EOL
      expect(output).to eq(text)
    end

    it "Configuring the Rails Router" do
      output = draw do
        resources :brands, only: [:index, :show] do
          resources :products, only: [:index, :show]
        end
        resource :basket, only: [:show, :update, :destroy]
      end
      # Shows must be :brand_id for brands#show due to APIGW sibling limitation
      text = <<~EOL
      brands         GET    /brands                        brands#index
      brand          GET    /brands/:id                    brands#show
      brand_products GET    /brands/:brand_id/products     products#index
      brand_product  GET    /brands/:brand_id/products/:id products#show
      basket         GET    /basket                        baskets#show
      basket         PUT    /basket                        baskets#update
      basket         PATCH  /basket                        baskets#update
      basket         DELETE /basket                        baskets#destroy
      EOL
      expect(output).to eq(text)
    end
  end
end
