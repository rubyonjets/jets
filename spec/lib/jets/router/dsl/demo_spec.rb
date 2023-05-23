describe Jets::Router do
  let(:route_set) { Jets.application.routes }
  let(:app)       { RouterTestApp.new }

  describe "Router" do
    it "demo" do
      output = draw do
        # only = [:new, :edit]
        # resources :comments, shallow: true, only: [] do
        #   resources :likes, only: [:index, :create, :new, :edit]
        # end

        # resources :posts, shallow: true do
        #   resources :comments, shallow: true do
        #     resources :likes
        #   end
        # end
        # resources :posts, only: only do
        #   resources :comments, only: only
        # end
      end
      # puts output
    end
  end
end
