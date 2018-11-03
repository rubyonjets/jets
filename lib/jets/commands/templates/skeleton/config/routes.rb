Jets.application.routes.draw do
  # Default homepage. This should be replaced. Replacing requires using JETS_ENV_EXTRA
  # or deleting and deploying twice.
  # More info:
  #   http://rubyonjets.com/docs/routes-workaround/
  #   http://rubyonjets.com/docs/env-extra/
  root "jets/public#show"

  # The jets/public#show controller can serve static utf8 content out of the public folder.
  # Note, as part of the deploy process Jets uploads files in the public folder to s3
  # and serves them out of s3 directly. S3 is well suited to serve static assets.
  # More info here: http://rubyonjets.com/docs/assets-serving/
  any "*catchall", to: "jets/public#show"
end
