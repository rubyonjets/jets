module Jets::Cfn
  class Teardown < Stack
    def run
      check_stack_exist!
      log.info "Final Delete Phase"
      Bucket.new.empty!
      remaining_resources
    end

    def remaining_resources
      stack_resources = cfn.describe_stack_resources(stack_name: stack_name).stack_resources
      resources = stack_resources.map(&:logical_resource_id).join(", ")
      log.debug "Remaining resources: #{resources}"
      log.debug "Final delete #{Jets.project.namespace.color(:green)}"
      cfn.delete_stack(stack_name: stack_name)
      cfn_status = Jets::Cfn::Status.new
      cfn_status.wait
    end
  end
end
