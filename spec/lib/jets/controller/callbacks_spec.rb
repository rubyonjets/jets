class FakeController < Jets::Controller::Base
  before_action :find_article
  def find_article; end
end

class WhateverController < Jets::Controller::Base
  before_action :find_whatever
  def find_whatever; end
end

describe Jets::Controller::Base do
  context FakeController do
    let(:controller) { FakeController.new({}, nil, "meth") }

    it "before_actions includes find_article only" do
      expect(controller.class.before_actions).to eq [[:find_article, {}]]
    end
  end

  context WhateverController do
    let(:controller) { WhateverController.new({}, nil, "meth") }

    it "before_actions includes find_whatever only" do
      expect(controller.class.before_actions).to eq [[:find_whatever, {}]]
    end
  end
end
