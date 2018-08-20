
module Jets
  class AwsInfo
    extend Memoist
    include AwsServices

    def region
      return 'us-east-1' if test?

      region = nil

      # First try to get it from the ~/.aws/config
      region = `aws configure get region`.strip rescue nil
      return region if region

      # Second try the metadata endpoint, should be available on AWS Lambda environment
      # https://stackoverflow.com/questions/4249488/find-region-from-within-an-ec2-instance
      begin
        az = `curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
        region = az.strip.chop # remove last char
      rescue
      end
      return region if region

      ENV['JETS_AWS_REGION'] || 'us-east-1' # default if all else fails
    end
    memoize :region

    # aws sts get-caller-identity
    def account
      return '123456789' if test?
      sts.get_caller_identity.account
    end
    memoize :account

    def test?
      ENV['TEST'] || ENV['CIRCLECI']
    end
  end
end