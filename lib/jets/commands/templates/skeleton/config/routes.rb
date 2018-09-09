Jets.application.routes.draw do
  # Required for API Gateway to serve static utf8 content out of public folder.
  # Replace with your own controller to customize.
  # Note: Binary files do not get served on AWS Lambda currently.
  any "*catchall", to: "jets/public#show"
end
