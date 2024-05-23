class Jets::CLI
  class Teardown < Base
    def run
      sure?("Will teardown the stack #{Jets.project.namespace}")
      Jets::Cfn::Teardown.new(@options).run
    end
  end
end
