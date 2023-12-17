module Jets::Command
  class StatusCommand < Base
    include Jets::AwsServices

    desc "status", "Shows the current status of the Jets app"
    long_desc Help.text(:status)
    def perform
      Jets.boot
      cfn_status = Jets::Cfn::Status.new
      success = cfn_status.run
      unless success
        cfn_status.failure_message!
      end
    end
  end
end
