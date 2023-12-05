module Jets
  class Preheat
    extend Memoist
    include Jets::AwsServices

    # Examples:
    #
    #   Jets::Preheat.warm("posts_controller-index")
    #   Jets::Preheat.warm("jets-preheat_job-warm")
    #
    def self.warm(function_name, options={})
      Preheat.new(options).warm(function_name)
    end

    def self.warm_all(options={})
      Preheat.new(options).warm_all
    end

    def initialize(options)
      @options = options # passed to Call.new options
      @options[:mute_output] = true if @options[:mute_output].nil?
      @options[:lambda_proxy] = false # do not transform controller event from {"event": "1"} to {"queryStringParameters":{"_prewarm":"1"}}
    end

    # Makes remote call to the Lambda function.
    def warm(function_name)
      Jets::Commands::Call::Caller.new(function_name, '{"_prewarm": "1"}', @options).run unless Jets.env.test?
    end

    # Loop through all methods for each class and makes special prewarm call to each method.
    def warm_all
      threads = []
      all_functions.each do |function_name|
        next if function_name.include?('jets-public_controller') # handled by warm_public_controller_more
        threads << Thread.new do
          warm(function_name)
        end
      end
      threads.each { |t| t.join }

      # Warm the these controllers more since they can be hit more often
      warm_public_controller_more

      # return the funciton names so we can see in the Lambda console
      # the functions being prewarmed
      all_functions
    end

    def warm_public_controller_more
      function_name = 'jets-public_controller-show' # key function name
      return unless all_functions.include?(function_name)

      public_ratio = Jets.config.prewarm.public_ratio
      return if public_ratio == 0

      puts "Prewarming the public controller extra at a ratio of #{public_ratio}" unless @options[:mute]

      threads = []
      public_ratio.times do
        threads << Thread.new do
          warm(function_name)
        end
      end
      threads.each { |t| t.join }
    end

    # Returns:
    #   [
    #     "demo-posts_controller-index",
    #     "demo-posts_controller-show",
    #     ...
    #   ]
    #
    #   or (for one lambda per controller)
    #
    #   [
    #     "demo-posts_controller",
    #     "demo-up_controller",
    #     ...
    #   ]
    def all_functions
      parent_stack = cfn.describe_stack_resources(stack_name: Jets::Names.parent_stack_name)
      parent_resources = parent_stack.stack_resources.select do |resource|
        resource.logical_resource_id =~ /Controller$/ # only controller functions
      end
      physical_resource_ids = parent_resources.map(&:physical_resource_id)
      resources = physical_resource_ids.inject([]) do |acc, physical_resource_id|
        stack_resources = cfn.describe_stack_resources(stack_name: physical_resource_id).stack_resources
        stack_resources.each do |stack_resource|
          acc << stack_resource if stack_resource.logical_resource_id.ends_with?('LambdaFunction') # only functions
        end
        acc
      end
      resources.map(&:physical_resource_id) # function names
    end
    memoize :all_functions

    def classes
      Jets::Cfn::Builder.app_files.map do |path|
        next if path.include?("preheat_job.rb") # dont want to cause an infinite loop, just in case
        next unless path =~ %r{app/controllers} # only prewarm controllers

        class_path = path.sub(%r{.*app/\w+/},'').sub(/\.rb$/,'')
        class_name = class_path.camelize
        # IE: PostsController
        class_name.constantize # load app/**/* class definition
      end.compact
    end
  end
end
