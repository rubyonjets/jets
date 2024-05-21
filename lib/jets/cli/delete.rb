class Jets::CLI
  class Delete < Base
    def run
      are_you_sure?
      Jets::Cfn::Bootstrap.new(@options).run
      Jets::Cfn::Delete.new(options).run
    end

    def are_you_sure?
      stack_name = Jets.project.namespace
      message = <<~EOL
        Will delete #{stack_name.color(:green)}

        Uses remote runner to delete the stack and resources.
      EOL
      unless stack_exists?(stack_name)
        message << <<~EOL

          Note: It looks like the stack #{stack_name} has already been deleted.
          Jets will create a dummy stack to delete the API deployment record.
          The dummy stack will be deleted immediately after.
        EOL
      end
      sure?(message)
    end
  end
end
