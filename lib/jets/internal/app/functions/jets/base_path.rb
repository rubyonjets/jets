begin
  require 'bundler/setup'
  # When require bundler/setup fails, AWS Lambda won't be able to load base_path_mapping
  # So we'll require base_path_mapping within begin/rescue block so that it does not also
  # fail the entire lambda function.
  require 'jets/internal/app/functions/jets/base_path_mapping'
rescue Exception => e
  # Note: rescue LoadError is not enough in AWS Lambda environment
  # Actual exceptions:
  #   require bundler/setup: Ruby exception "Bundler::GemNotFound"
  #   require base_path_mappnig: AWS Lambda reported error "errorType": "Init<LoadError>"
  # Will use a generic rescue Exception though in case error changes in the future.
  puts "WARN: #{e.class} #{e.message}"
  puts <<~EOL
    Could not require bundler/setup.
    This can happen for weird timeout missing error. Example:

        Could not find timeout-0.3.2 in locally installed gems

    Happens when the gem command is out-of-date on old versions of ruby 2.7.
    See: https://community.boltops.com/t/could-not-find-timeout-0-3-1-in-any-of-the-sources/996
  EOL
end
require 'cfn_response'

STAGE_NAME = "<%= @stage_name %>"

def lambda_handler(event:, context:)
  cfn = CfnResponse.new(event, context)
  cfn.response do
    # Super edge case: mapping is nil when require bundler/setup fails
    begin
      mapping = BasePathMapping.new(event, STAGE_NAME)
    rescue NameError => e
      puts "ERROR: #{e.class} #{e.message}"
      puts error_message
    end

    # This is the "second pass" of CloudFormation when it tries to delete the BasePathMapping during rollback
    if mapping.nil? && event['RequestType'] == "Delete"
      cfn.success # so that CloudFormation can continue the delete process from a rollback
      delay
      return
    end

    # Normal behavior when mapping is not nil when bundler/setup loads successfully
    case event['RequestType']
    when "Create", "Update"
      mapping.update
    when "Delete"
      mapping.delete(true) if mapping.should_delete?
    end
  end
end

def delay
  puts "Delaying 60 seconds to allow user some time to see lambda function logs."
  60.times do
    puts Time.now
    sleep 1
  end
end

def error_message
  <<~EOL
  This is ultimately the result of require bundler/setup failing to load.
  On the CloudFormation first pass, the BasePathMapping fails to CREATE.
  CloudFormation does a rollback and tries to delete the BasePathMapping.

  Jets will send a success response to CloudFormation so it can continue and delete
  BasePathMapping on the rollback. Otherwise, CloudFormation ends up in the terminal
  UPDATE_FAILED state and the CloudFormation console provides 3 options:

      1) retry 2) update 3) rollback.

  The only option that seems to work is rollback to get it out of UPDATE_FAILED to
  UPDATE_ROLLBACK_COMPLETE. But then, if we `jets deploy` again without fixing the
  require bundler/setup issue, we'll end back up in the UPDATE_FAILED state.

  Will handle this error so we can continue the stack because we do not want it to fail
  and never be able to send the CfnResponse. Then we have to wait hours for a CloudFormation timeout.
  Sometimes deleting the APP-dev-ApiDeployment20230518230443-EXAMPLEY8YQP0 stack
  allows the cloudformation stacks to continue, but usually, it'll only just slightly speed up the rollback.

  Some examples of actual rollback times:

  When left alone, the rollback takes about 2.5 hours.

      2023-05-19 05:39:25  User Initiated
      2023-05-19 08:01:48  UPDATE_ROLLBACK_COMPLETE

  When deleting the APP-dev-ApiDeployment20230518230443-EXAMPLEY8YQP0 stack, it takes about 1.5 hours.

      2023-05-19 06:25:41  User Initiated
      2023-05-19 07:47:03  UPDATE_ROLLBACK_COMPLETE

  Rescuing and handling the error here allows the CloudFormation stack to continue and finish the rollback process.
  It takes the rollback time down to about 3 minutes. Example:

      2023-05-19 16:34:19 User Initiated
      2023-05-19 16:37:34 UPDATE_ROLLBACK_COMPLETE

  Note: The first cloudformation CREATE pass sends FAILED Status to CloudFormation,
  and the second cloudformation DELETE pass sends SUCCESS Status to CloudFormation.

  Related: https://community.boltops.com/t/could-not-find-timeout-0-3-1-in-any-of-the-sources/996
  EOL
end
