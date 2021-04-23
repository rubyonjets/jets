
module Jets
  class AwsInfo
    extend Memoist
    include AwsServices

    def region
      return 'us-east-1' if Jets.env.test?

      return ENV['JETS_AWS_REGION'] if ENV['JETS_AWS_REGION'] # highest precedence
      return ENV['AWS_REGION'] if ENV['AWS_REGION']

      region = nil

      # First if aws binary is available
      # try to get it from the ~/.aws/config
      if which('aws')
        region = `aws configure get region 2>&1`.strip rescue nil
        exit_code = $?.exitstatus
        if exit_code != 0
          exception_message = region.split("\n").grep(/botocore\.exceptions/).first
          if exception_message
            puts "WARN: #{exception_message}".color(:yellow)
          else
            # show full message as warning
            puts region.color(:yellow)
          end
          puts "You can also get rid of this message by setting AWS_REGION or configuring ~/.aws/config with the region"
          region = nil
        end
        region = nil if region == ''
        return region if region
      end

      # Second try the metadata endpoint, should be available on AWS Lambda environment
      # https://stackoverflow.com/questions/4249488/find-region-from-within-an-ec2-instance
      begin
        az = `curl -s --max-time 3 --connect-timeout 5 http://169.254.169.254/latest/meta-data/placement/availability-zone`
        region = az.strip.chop # remove last char
        region = nil if region == ''
      rescue
      end
      return region if region

      'us-east-1' # default if all else fails
    end
    memoize :region

    # aws sts get-caller-identity
    def account
      return '123456789' if Jets.env.test?
      return ENV['JETS_AWS_ACCOUNT'] if ENV['JETS_AWS_ACCOUNT']

      # ensure region set, required for sts.get_caller_identity.account to work
      ENV['AWS_REGION'] ||= region
      begin
        sts.get_caller_identity.account
      rescue Aws::Errors::MissingCredentialsError, Aws::Errors::NoSuchEndpointError, Aws::STS::Errors::InvalidClientTokenId
        puts "INFO: You're missing AWS credentials. Only local services are currently available"
      rescue Seahorse::Client::NetworkingError
        puts "INFO: No internet connection available. Only local services are currently available"
      end
    end
    memoize :account

    # If bucket does not exist, do not use the cache value and check for the bucket again.
    # This is because we can build the app before deploying it for the first time.
    # The deploy sequence ensure an minimal stack exists and will return a s3 bucket
    # value for real deployments though, just not for the `jets build` only command.
    BUCKET_DOES_NOT_YET_EXIST = "bucket-does-not-yet-exist" # use const to save from misspellings
    @@s3_bucket = BUCKET_DOES_NOT_YET_EXIST
    def s3_bucket
      return "fake-test-s3-bucket" if Jets.env.test?
      return @@s3_bucket unless @@s3_bucket == BUCKET_DOES_NOT_YET_EXIST

      resp = cfn.describe_stacks(stack_name: Jets::Naming.parent_stack_name)
      stack = resp.stacks.first
      output = stack["outputs"].find { |o| o["output_key"] == "S3Bucket" }
      @@s3_bucket = output["output_value"] # s3_bucket
    rescue Exception => e
      # When user uses Jets::Application.default_iam_policy in their config/application.rb
      # it looks up the s3 bucket for the iam policy, but the project name has
      # not been loaded in the config yet.  We do some trickery with loading
      # the config twice in Application#load_app_config
      # The first load will result in a Aws::CloudFormation::Errors::ValidationError
      # since the Jets::Naming.parent_stack_name has not been properly set yet.
      #
      # Rescuing all exceptions in case there are other exceptions dont know about yet
      # Here are the known ones: Aws::CloudFormation::Errors::ValidationError, Aws::CloudFormation::Errors::InvalidClientTokenId
      BUCKET_DOES_NOT_YET_EXIST
    end

    private

    # Cross-platform way of finding an executable in the $PATH.
    #
    #   which('ruby') #=> /usr/bin/ruby
    #
    # source: https://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
    def which(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each { |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable?(exe) && !File.directory?(exe)
        }
      end
      return nil
    end
  end
end
