class TestAuthController < Jets::Controller::Base
  authorizer "main#protect"
end

class TestAuthOnlyController < Jets::Controller::Base
  authorizer "main#protect", only: [:index]
end

class TestAuthExceptController < Jets::Controller::Base
  authorizer "main#protect", only: [:show]
end

describe Jets::Controller::Authorization do
  context "no filter options" do
    let(:controller) { TestAuthController }
    it "logical_id" do
      logical_id = controller.authorizer_logical_id("index")
      expect(logical_id).to eq "MainProtectAuthorizer"
    end
  end

  context "only filter" do
    let(:controller) { TestAuthOnlyController }
    it "logical_id" do
      logical_id = controller.authorizer_logical_id("index")
      expect(logical_id).to eq "MainProtectAuthorizer"
      logical_id = controller.authorizer_logical_id("show")
      expect(logical_id).to be nil
    end
  end

  context "except filter" do
    let(:controller) { TestAuthExceptController }
    it "logical_id" do
      logical_id = controller.authorizer_logical_id("index")
      expect(logical_id).to be nil
      logical_id = controller.authorizer_logical_id("show")
      expect(logical_id).to eq "MainProtectAuthorizer"
    end
  end
end
