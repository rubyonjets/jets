
module Jets
  class AwsInfo
    extend Memoist
    include AwsServices

    def region
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

    def account_id
      # aws sts get-caller-identity
      sts.get_caller_identity.account
    end
    memoize :account_id
  end
end