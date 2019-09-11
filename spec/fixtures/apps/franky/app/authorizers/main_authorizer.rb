class MainAuthorizer < ApplicationAuthorizer
  authorizer(
    name: "MainProtect",  # required
    type: :token,
  )
  def protect
    resource = event[:methodArn] # "arn:aws:execute-api:us-west-2:123456789012:ymy8tbxw7b/*/GET/"
    build_policy(resource, "current_user")
  end

  authorizer(
    name: "MainLock",  # required
    # type: :request,  # default: request
  )
  def lock
    resource = event[:methodArn] # "arn:aws:execute-api:us-west-2:123456789012:ymy8tbxw7b/*/GET/"
    build_policy(resource, "current_user")
  end

  authorizer(
    name: "MainCognito",  # required
    type: :cognito_user_pools,
    provider_arns: [
      "arn:aws:cognito-idp:us-west-2:112233445566:userpool/us-west-2_DjXxf8cP7",
    ],
  )
  # no function
end
