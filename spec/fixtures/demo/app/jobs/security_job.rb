class SecurityJob < ApplicationJob
  rule_event(
    source: ["aws.ec2"],
    detail_type: ["EC2 Instance State-change Notification"],
    detail: {
      state: ["stopping"],
    }
  )
  rule_event(
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
