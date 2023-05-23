require 'aws-sdk-apigateway'
require 'aws-sdk-cloudformation'

class BasePathMapping
  def initialize(event, stage_name)
    @event, @stage_name = event, stage_name
    aws_config_update!
  end

  # Override the AWS retry settings. The aws-sdk-core has expondential backup with this formula:
  #
  #   2 ** c.retries * c.config.retry_base_delay
  #
  # So the max delay will be 2 ** 7 * 0.6 = 76.8s
  #
  # Useful links:
  #
  #   https://github.com/aws/aws-sdk-ruby/blob/master/gems/aws-sdk-core/lib/aws-sdk-core/plugins/retry_errors.rb
  #   https://docs.aws.amazon.com/apigateway/latest/developerguide/limits.html
  #
  def aws_config_update!
    Aws.config.update(
      retry_limit: 7, # default: 3
      retry_base_delay: 0.6, # default: 0.3
    )
  end

  # Cannot use update_base_path_mapping to update the base_mapping because it doesnt
  # allow us to change the rest_api_id. So we delete and create.
  def update
    puts "BasePathMapping update"
    if rest_api_changed?
      delete(true)
      create
    else
      puts "BasePathMapping update: rest_api_id #{rest_api_id} did not change. Skipping."
    end

    puts "BasePathMapping update complete"
  end

  def rest_api_changed?
    puts "BasePathMapping checking if rest_api_id changed"
    mapping = current_base_path_mapping
    return true unless mapping
    mapping.rest_api_id != rest_api_id
  end

  def current_base_path_mapping
    resp = apigateway.get_base_path_mapping(base_path: "(none)", domain_name: domain_name)
  rescue Aws::APIGateway::Errors::NotFoundException
    return nil
  end

  # Dont delete the newly created base path mapping unless this is an operation
  # where we're fully deleting the stack
  def should_delete?
    deleting_parent?
  end

  def delete(fail_silently=false)
    puts "BasePathMapping delete"
    options = {
      domain_name: domain_name, # required
      base_path: base_path.empty? ? '(none)' : base_path,
    }
    puts "BasePathMapping delete options #{options.inspect}"
    apigateway.delete_base_path_mapping(options)
    wait_for_delete
    puts "BasePathMapping delete complete"
  # https://github.com/tongueroo/jets/issues/255
  # Used to return: Aws::APIGateway::Errors::NotFoundException
  # Now returns: Aws::APIGateway::Errors::InternalFailure
  # So we'll use a more generic error
  rescue Aws::APIGateway::Errors::ServiceError => e
    raise(e) unless fail_silently
  end

  # Wait for deletion to complete
  # Otherwise, CloudFormation continues too fast during a `jets delete`
  # and the initially fails deletion. CloudFormaton then retries until it's successfully.
  # The stack ultimately finishes deleting successfully but the error messages
  # are confusing to the user.
  def wait_for_delete
    loop do
      resp = apigateway.get_base_path_mapping(
        domain_name: domain_name,
        base_path: base_path.empty? ? '(none)' : base_path,
      )
      break if resp.nil? || resp.empty?
      sleep(5)
    end
  rescue Aws::APIGateway::Errors::NotFoundException
    nil
  end

  def create
    puts "BasePathMapping create"
    options = {
      domain_name: domain_name, # required
      base_path: base_path,
      rest_api_id: rest_api_id, # required
      stage: @stage_name,
    }
    puts "BasePathMapping create options #{options.inspect}"
    apigateway.create_base_path_mapping(options)
    puts "BasePathMapping create complete"
  rescue Aws::APIGateway::Errors::ServiceError => e
    puts "ERROR: #{e.class}: #{e.message}"
    puts "BasePathMapping create failed"
    if e.message.include?("Invalid domain name identifier specified")
      puts <<~EOL
        This super edge case error seems to happen when the cloudformation stack does a rollback
        because the BasePathMapping custom resource fails. This has happened with a strange combination of
        ruby 2.7 and the timeout gem not being picked up in the AWS Lambda runtime environment
        Specifically, when jets deploy was used with a rubygems install that is out-of-date.
        See: https://community.boltops.com/t/could-not-find-timeout-0-3-1-in-any-of-the-sources/996

        The new base path mapping is not created correctly and the old base path mapping is not properly deleted.
        The old ghost base mapping interferes with the new base path mapping.
        The workaround solution seems to require removing all the config.domain settings and deploying again. Example:

        config/application.rb

            config.domain.cert_arn = "arn:aws:acm:us-west-2:111111111111:certificate/EXAMPLE1-a3de-4fe7-b72e-4cc153c5303e"
            config.domain.hosted_zone_name = "example.com"

        Comment out those settings, deploy, then uncomment and deploy again.
        If there's a better workaround, please let us know.
      EOL
    end
    raise(e)
  end

  def mapping_stack
    @mapping_stack ||= cfn.describe_stacks(stack_name: @event['StackId']).stacks.first
  end

  def rest_api_id
    @rest_api_id ||= parameter_value('RestApi')
  end

  def domain_name
    @domain_name ||= parameter_value('DomainName')
  end

  def base_path
    @base_path ||= parameter_value('BasePath') || ''
  end

  def parameter_value(parameter_key)
    puts "mapping_stack #{mapping_stack.inspect}"
    param = mapping_stack[:parameters].find { |p| p.parameter_key == parameter_key }
    param&.parameter_value # possible for this to be nil when removing the config: IE: config.domain.name = nil
  end

  def deleting_parent?
    stack = cfn.describe_stacks(stack_name: parent_stack_name).stacks.first
    stack.stack_status == 'DELETE_IN_PROGRESS'
  end

  def parent_stack_name
    mapping_stack[:root_id]
  end

  def apigateway
    @apigateway ||= Aws::APIGateway::Client.new(aws_options)
  end

  def cfn
    @cfn ||= Aws::CloudFormation::Client.new(aws_options)
  end

  def aws_options
    options = {
      retry_limit: 7, # default: 3
      retry_base_delay: 0.6, # default: 0.3
    }
    options.merge!(
      log_level: :debug,
      logger: Logger.new($stdout),
    ) if ENV['JETS_DEBUG_AWS_SDK']
    options
  end
end

if __FILE__ == $0
  event = JSON.load(File.read(ARGV[0]))
  stage_name = 'dev' # change to test
  BasePathMapping.new(event, stage_name).update
end
