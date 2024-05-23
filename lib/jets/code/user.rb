require "aws-sdk-iam"

class Jets::Code
  class User
    delegate :build_root, to: Jets

    def save
      user = iam_user || ENV["USER"] || ENV["JETS_DEPLOY_USER"]
      FileUtils.mkdir_p(File.dirname(user_file))
      IO.write(user_file, user)
      user
    end

    def user_file
      "#{build_root}/stage/code/.jets/deploy_user"
    end

    def iam_user
      @iam ||= Aws::IAM::Client.new
      @iam.get_user.user.user_name
    rescue Aws::IAM::Errors::ValidationError
    end
  end
end
