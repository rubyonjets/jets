module Jets::Command
  class StatusCommand < Base
    desc "status", "Shows the current status of the Jets app"
    long_desc Help.text(:status)
    def perform
      Jets::Cfn::Status.new(options).run
    end
  end
end
