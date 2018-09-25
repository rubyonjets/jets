class SecurityJob < ApplicationJob
  event_pattern(
    source: ["aws.ec2"],
    detail_type: ["EC2 Instance State-change Notification"],
    detail: {
      state: ["stopping"],
    }
  )
  event_pattern(
    detail_type: ["AWS API Call via CloudTrail"],
    detail: {
      userIdentity: {
        type: ["Root"]
      }
    }
  )
  rate "10 hours"
  def lock
  end
end
