module Jets::Cfn
  class Delete < Stack
    def run
      bootstrap_if_needed
      Jets::Remote::Runner.new(@options.merge(dummy: true, command: "delete")).run
      Teardown.new(@options).run
    end

    # In case user has deleted stack already and needs to delete the Jets API deployment record.
    def bootstrap_if_needed
      stack_name = Jets.project.namespace
      return if stack_exists?(stack_name)
      log.info "Creating dummy stack for deletion: #{stack_name}"
      Jets::Cfn::Bootstrap.new(@options).run
    end
  end
end
