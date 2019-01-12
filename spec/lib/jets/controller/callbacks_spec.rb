class FakeController < Jets::Controller::Base
  before_action :find_article
  def find_article; end
end

class WhateverController < Jets::Controller::Base
  before_action :find_whatever
  def find_whatever; end
end

class BreakableController < Jets::Controller::Base
  before_action :breakable_action
  before_action :another_action

  def index
    raise "should not get here"
  end

  def breakable_action
    render json: {}, status: 404
  end

  def another_action
    raise "should not get here"
  end
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

  context BreakableController do
    let(:controller) { BreakableController.new({}, nil, :index) }

    it "breaks before reaching index" do
      response = controller.dispatch!
      expect(response[0]).to eq '404'
      expect(response[2].read).to eq '{}'
    end
  end
end
