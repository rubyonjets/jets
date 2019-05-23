module Jets::CommonMethods
  extend Memoist
  # Add API Gateway Stage Name
  def add_stage_name(url)
    Jets::Controller::Stage.add(request.host, url)
  end

  def on_aws?
    on_cloud9 = Jets::Controller::Stage.on_cloud9?(request.headers['HTTP_HOST'])
    !request.headers['HTTP_X_AMZN_TRACE_ID'].nil? && !on_cloud9
  end
  memoize :on_aws?
end
