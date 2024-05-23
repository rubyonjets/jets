module Jets::Cfn
  class Rollback < Stack
    def run
      check_deployable!
      Jets::Remote::Runner.new(@options.merge(dummy: true, command: "rollback")).run
    end
  end
end
