class Jets::CLI
  class Bootstrap < Base
    def run
      are_you_sure?
      Jets::Cfn::Bootstrap.new(@options).run
    end

    def are_you_sure?
      return if @options[:yes]
      sure?("Will bootstrap #{stack_name.color(:green)}")
    end

    def stack_name
      Jets::Names.parent_stack_name
    end
  end
end
