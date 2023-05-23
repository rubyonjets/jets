module Jets::Controller::Decorate
  module UrlFor
    include ApigwStage

    def url_for(options = nil)
      url = super
      add_apigw_stage(url)
    end
  end
end
