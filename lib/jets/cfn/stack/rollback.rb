class Jets::Cfn::Stack
  module Rollback
    include Jets::AwsServices::AwsHelpers
    include Jets::Util::Logging

    # Super edge case: UPDATE_ROLLBACK_FAILED status
    # The continue_update_rollback! addresses this edge case.
    # Note: We do not provide any resources to skip.
    # Also, tough to reproduce this edge case.  Unsure how got to it.
    #
    # Related:
    # Gist with Error: https://gist.github.com/tongueroo/d752186375ea95ed310e6735de24a324
    # AWS Troubleshooting Update rollback failed: https://go.aws/49m3Ji3
    # AWS cli continue-update-rollback: https://go.aws/43OiLw2
    def continue_update_rollback!
      return unless update_rollback_failed?

      log.info "Continuing update rollback"
      cfn.continue_update_rollback(stack_name: stack_name)
      cfn_status.wait
      cfn_status.reset
    end

    def update_rollback_failed?
      stack = find_stack(stack_name)
      return false unless stack

      stack.stack_status == "UPDATE_ROLLBACK_FAILED"
    end

    # Delete existing rollback stack from previous bad bootstrap deploy
    def delete_rollback_complete!
      return unless rollback_complete?

      log.info "Existing stack is in ROLLBACK_COMPLETE"
      log.info "Deleting stack before continuing"
      cfn.delete_stack(stack_name: stack_name)
      cfn_status.wait
      cfn_status.reset
    end

    # Checks for a few things before deciding to delete the parent stack
    #
    #   * Parent stack status status is ROLLBACK_COMPLETE
    #   * Parent resources are in the DELETE_COMPLETE state
    #
    def rollback_complete?
      stack = find_stack(stack_name)
      return false unless stack

      return false unless stack.stack_status == "ROLLBACK_COMPLETE"

      # Finally check if all the minimal resources in the parent template have been deleted
      resp = cfn.describe_stack_resources(stack_name: stack_name)
      resource_statuses = resp.stack_resources.map(&:resource_status).uniq
      resource_statuses == ["DELETE_COMPLETE"]
    end
  end
end
