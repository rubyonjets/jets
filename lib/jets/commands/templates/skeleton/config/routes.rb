Jets.application.routes.draw do
  # Default homepage. This should be replaced. Replacing requires using JETS_ENV_EXTRA
  # or deleting and deploying twice.
  # More info:
  #   http://rubyonjets.com/docs/routes-workaround/
  #   http://rubyonjets.com/docs/env-extra/
  root "jets/welcome#index"

  # Required for API Gateway to serve static utf8 content out of public folder.
  # Replace with your own controller to customize.
  any "*catchall", to: "jets/public#show"
end
