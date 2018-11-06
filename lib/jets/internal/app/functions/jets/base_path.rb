require 'aws-sdk-apigateway'
require 'aws-sdk-cloudformation'

STAGE_NAME = "<%= @stage_name %>"

def lambda_handler(event:, context:)
  puts("event['RequestType'] #{event['RequestType']}")
  puts("event: #{JSON.dump(event)}")
  puts("context: #{JSON.dump(context)}")
  puts("context.log_stream_name #{context.log_stream_name.inspect}")

  mimic = event['ResourceProperties']['Mimic']
  physical_id = event['ResourceProperties']['PhysicalId'] || "PhysicalId"

  puts "mimic: #{mimic}"
  puts "physical_id: #{physical_id}"

  if event['RequestType'] == 'Delete'
    if mimic == 'FAILED'
      send_response(event, context, "FAILED")
    else
      mapping = BasePathMapping.new(event)
      mapping.delete(true) if mapping.should_delete?
      send_response(event, context, "SUCCESS")
    end
    return # early return
  end

  mapping = BasePathMapping.new(event)
  mapping.update

  response_status = mimic == "FAILED" ? "FAILED" : "SUCCESS"
  response_data = { "Hello" => "World" }

  send_response(event, context, response_status, response_data, physical_id)

# We rescue all exceptions and send an message to CloudFormation so we dont have to
# wait for over an hour for the stack operation to timeout and rollback.
rescue Exception => e
  puts e.message
  puts e.backtrace
  sleep 10 # provide delete to make sure that the log gets sent to CloudWatch
  send_response(event, context, "FAILED")
end

def send_response(event, context, response_status, response_data={}, physical_id="PhysicalId")
  response_body = JSON.dump(
    Status: response_status,
    Reason: "See the details in CloudWatch Log Stream: #{context.log_stream_name.inspect}",
    PhysicalResourceId: physical_id,
    StackId: event['StackId'],
    RequestId: event['RequestId'],
    LogicalResourceId: event['LogicalResourceId'],
    Data: response_data
  )

  puts "RESPONSE BODY:\n"
  puts response_body

  url = event['ResponseURL']
  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.open_timeout = http.read_timeout = 30
  http.use_ssl = true if uri.scheme == 'https'


  # must used url to include the AWSAccessKeyId and Signature
  req = Net::HTTP::Put.new(url) # url includes query string and uri.path does not, must used url t
  req.body = response_body
  req.content_length = response_body.bytesize

  # set headers
  req['content-type'] = ''
  req['content-length'] = response_body.bytesize

  res = http.request(req)
  puts "status code: #{res.code}"
  puts "headers: #{res.each_header.to_h.inspect}"
  puts "body: #{res.body}"
end


class BasePathMapping
  def initialize(event)
    @event = event
    @rest_api_id = get_rest_api_id
    @domain_name = get_domain_name
    @base_path = ''
  end

  def update
    # Cannot use update_base_path_mapping to update the base_mapping because it doesnt
    # allow us to change the rest_api_id. So we delete and create.
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
      domain_name: @domain_name, # required
      base_path: '(none)',
    )
  rescue Aws::APIGateway::Errors::NotFoundException => e
    raise(e) unless fail_silently
  end

  def create
    apigateway.create_base_path_mapping(
      domain_name: @domain_name, # required
      base_path: @base_path,
      rest_api_id: @rest_api_id, # required
      stage: STAGE_NAME,
    )
  end

  def get_domain_name
    param = deployment_stack[:parameters].find { |p| p.parameter_key == 'DomainName' }
    param.parameter_value
  end

  def deployment_stack
    @deployment_stack ||= cfn.describe_stacks(stack_name: @event['StackId']).stacks.first
  end

  def get_rest_api_id
    param = deployment_stack[:parameters].find { |p| p.parameter_key == 'RestApi' }
    param.parameter_value
  end

  def deleting_parent?
    stack = cfn.describe_stacks(stack_name: parent_stack_name).stacks.first
    stack.stack_status == 'DELETE_IN_PROGRESS'
  end

  def parent_stack_name
    deployment_stack[:root_id]
  end

private
  def apigateway
    @apigateway ||= Aws::APIGateway::Client.new
  end

  def cfn
    @cfn ||= Aws::CloudFormation::Client.new
  end
end
