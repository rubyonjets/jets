require 'bundler/setup'
require 'cfn_response'
require 'jets/internal/app/functions/jets/base_path_mapping'

STAGE_NAME = "<%= @stage_name %>"

def lambda_handler(event:, context:)
  cfn = CfnResponse.new(event, context)
  cfn.response do
    mapping = BasePathMapping.new(event, STAGE_NAME)
    case event['RequestType']
    when "Create", "Update"
      mapping.update
    when "Delete"
      mapping.delete(true) if mapping.should_delete?
    end
  end
end
