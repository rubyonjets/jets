require "aws-sdk-ssm"

module Jets::Core::Config::Helpers
  module Ssm
    def ssm_env
      Jets::Dotenv::Convention.ssm_env
    end
  end
end
