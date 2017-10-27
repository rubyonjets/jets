class Jets::Cfn::Delete
  include Jets::Cfn::AwsServices
  include Jets::Cfn::Util

  def initialize(stack_name, options={})
    @stack_name = stack_name
    @options = options
    @project_root = options[:project_root] || '.'
  end

  def run
    message = "Deleted #{@stack_name} stack."
    if @options[:noop]
      puts "NOOP #{message}"
    else
      are_you_sure?(:delete)

      if stack_exists?(@stack_name)
        cfn.delete_stack(stack_name: @stack_name)
        puts message
      else
        puts "#{@stack_name.inspect} stack does not exist".colorize(:red)
      end
    end
  end
end
