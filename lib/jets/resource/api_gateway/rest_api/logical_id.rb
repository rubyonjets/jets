class Jets::Resource::ApiGateway::RestApi
  class LogicalId
    extend Memoist
    include Jets::AwsServices

    def get
      return default if ENV['JETS_BUILD_NO_INTERNET']
      return default unless stack_exists?(parent_stack_name) && api_gateway_exists?

      if changed?
        auto_replace_prompt
        new_id
      else
        current
      end
    end

    def auto_replace_prompt
      return if ENV['JETS_API_AUTO_REPLACE']
      return unless ARGV[0] == "deploy"
      case Jets.config.api.auto_replace
      when nil
        puts message.routes_changed
        puts message.custom_domain
        print "Would you like to continue the deployment? (y/N) "
        answer = get_answer
        exit 1 unless answer =~ /^y/
      when false
        puts message.routes_changed
        puts message.auto_replace_disabled
        exit 1
      end
    end

    def message
      Message.new
    end
    memoize :message

    TIMEOUT_PERIOD = 120
    def get_answer
      Timeout::timeout(TIMEOUT_PERIOD) do
        $stdin.gets
      end
    rescue Timeout::Error => e
      puts "#{e.class}: #{e.message}".color(:red)
      puts "Deployment timeout after #{TIMEOUT_PERIOD}s. Waited too long answer. Exiting."
      exit 1
    end

    def changed?
      change_detection = ChangeDetection.new
      change_detection.changed?
    end

    # Takes current logical id and increments the number that is appended to it.
    #
    # Examples:
    #
    #   RestApi => RestApi1
    #   RestApi1 => RestApi2
    #   RestApi2 => RestApi3
    #   RestApi7 => RestApi8
    def new_id
      regexp = /(\d+)/
      md = current.match(regexp)
      if md
        current.gsub(regexp,'') + (md[1].to_i + 1).to_s
      else
        current + "1"
      end
    end

    def current
      resources = cfn.describe_stack_resources(stack_name: api_gateway_stack_arn).stack_resources
      rest_api = resources.find { |r| r.resource_type == 'AWS::ApiGateway::RestApi' }
      rest_api.logical_resource_id
    end
    memoize :current

    def api_gateway_stack_arn
      stack = cfn.describe_stacks(stack_name: parent_stack_name).stacks.first
      lookup(stack[:outputs], "ApiGateway") # api_gateway_stack_arn
    end

    def api_gateway_exists?
      !!api_gateway_stack_arn
    end

    def parent_stack_name
      Jets::Naming.parent_stack_name
    end

    def default
      "RestApi"
    end
  end
end
