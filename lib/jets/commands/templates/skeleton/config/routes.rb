Jets.application.routes.draw do
  # Default homepage. This should be replaced. Replacing requires using JETS_ENV_EXTRA
  # or deleting and deploying twice.
  # More info:
  #   http://rubyonjets.com/docs/routes-workaround/
  #   http://rubyonjets.com/docs/env-extra/
  root "jets/public#show"

  # The jets/public#show controller serves static utf8 content out of the public folder.
  # Replace it with your own controller to customize.
  # Note, binary files do not get served on AWS Lambda unless you specify the Accept header.
  # This is problematic for images requested by the Browser. IE: We don't control
  # that accept header that the browser sends.
  # Caveat, setting the Accept header to '*' for the entire API Gateway settings will force
  # the public controller to serve binary data when requested by the browser, but it
  # also results in form data always being treated as binary data also.
  # Instead, it is recommended to serve binary data using s3.
  # More info here: http://rubyonjets.com/docs/assets-serving/
  any "*catchall", to: "jets/public#show"
end
