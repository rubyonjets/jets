require 'aws-sdk-apigateway'
require 'aws-sdk-cloudformation'

class BasePathMapping
  def initialize(event, stage_name)
    @event, @stage_name = event, stage_name
  end

  # Cannot use update_base_path_mapping to update the base_mapping because it doesnt
  # allow us to change the rest_api_id. So we delete and create.
  def update
    delete(true)
    create
  end

  # Dont delete the newly created base path mapping unless this is an operation
  # where we're fully deleting the stack
  def should_delete?
    deleting_parent?
  end

  def delete(fail_silently=false)
    apigateway.delete_base_path_mapping(
      domain_name: domain_name, # required
      base_path: base_path.empty? ? '(none)' : base_path,
    )
  # https://github.com/tongueroo/jets/issues/255
  # Used to return: Aws::APIGateway::Errors::NotFoundException
  # Now returns: Aws::APIGateway::Errors::InternalFailure
  # So we'll use a more generic error
  rescue Aws::APIGateway::Errors::ServiceError => e
    raise(e) unless fail_silently
  end

  def create
    apigateway.create_base_path_mapping(
      domain_name: domain_name, # required
      base_path: base_path,
      rest_api_id: rest_api_id, # required
      stage: @stage_name,
    )
  end

  def deployment_stack
    @deployment_stack ||= cfn.describe_stacks(stack_name: @event['StackId']).stacks.first
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
    param = deployment_stack[:parameters].find { |p| p.parameter_key == parameter_key }
    param&.parameter_value # possible for this to be nil when removing the config: IE: config.domain.name = nil
  end

  def deleting_parent?
    stack = cfn.describe_stacks(stack_name: parent_stack_name).stacks.first
    stack.stack_status == 'DELETE_IN_PROGRESS'
  end

  def parent_stack_name
    deployment_stack[:root_id]
  end

  def apigateway
    @apigateway ||= Aws::APIGateway::Client.new
  end

  def cfn
    @cfn ||= Aws::CloudFormation::Client.new
  end
end
