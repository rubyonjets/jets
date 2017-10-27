class Jets::Cfn::Create < Jets::Cfn::Base
  # save_stack is the interface method
  def save_stack(params)
    create_stack(params)
  end

  # aws cloudformation create-stack --stack-name prod-hi-123456789 --parameters file://output/params/prod-hi-123456789.json --template-body file://output/prod-hi.json
  def create_stack(params)
    message = "Creating #{@stack_name} stack."
    if @options[:noop]
      puts "NOOP #{message}"
      return
    end

    if stack_exists?(@stack_name)
      puts "Cannot create '#{@stack_name}' stack because it already exists.".colorize(:red)
      return
    end

    unless File.exist?(@template_path)
      puts "Cannot create '#{@stack_name}' template not found: #{@template_path}."
      return
    end

    template_body = IO.read(@template_path)
    cfn.create_stack(
      stack_name: @stack_name,
      template_body: template_body,
      parameters: params,
      capabilities: capabilities, # ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
      disable_rollback: !@options[:rollback],
    )
    puts message unless @options[:mute]
  end

  # Appends a short random string at the end of a stack name.
  # Later we will strip this same random string from the template name.
  # Very makes it convenient.  We can just type:
  #
  #   lono cfn create main --randomize-stack-name
  #
  # instead of:
  #
  #   lono cfn create main-[RANDOM] --template main
  #
  # The randomize_stack_name can be specified at the CLI but can also be saved as a
  # preference.
  #
  # It is not a default setting because it might confuse new lono users.
  def randomize(stack_name)
    if randomize_stack_name?
      random = (0...3).map { (65 + rand(26)).chr }.join.downcase # Ex: jhx
      [stack_name, random].join('-')
    else
      stack_name
    end
  end

end
