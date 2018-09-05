module Jets
  class Preheat
    extend Memoist

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
    end

    # Makes remote call to the Lambda function.
    def warm(function_name)
      Jets::Commands::Call.new(function_name, '{"_prewarm": "1"}', @options).run unless ENV['TEST']
    end

    # Loop through all methods for each class and makes special prewarm call to each method.
    def warm_all
      threads = []
      all_functions.each do |function_name|
        threads << Thread.new do
          warm(function_name)
        end
      end
      threads.each { |t| t.join }

      # Warm the jets-public_controller more since it gets called more naturally
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
    #     "posts_controller-index",
    #     "posts_controller-show",
    #     ...
    #   ]
    def all_functions
      classes.map do |klass|
        tasks = klass.tasks.select { |t| t.lang == :ruby } # only prewarm ruby functions
        tasks.map do |task|
          meth = task.meth
          underscored = klass.to_s.underscore.gsub('/','-')
          "#{underscored}-#{meth}" # function_name
        end
      end.flatten.uniq.compact
    end
    memoize :all_functions

    def classes
      Jets::Commands::Build.app_files.map do |path|
        next if path.include?("preheat_job.rb") # dont want to cause an infinite loop
        next if path =~ %r{app/functions} # dont support app/functions

        class_path = path.sub(%r{.*app/\w+/},'').sub(/\.rb$/,'')
        class_name = class_path.classify
        # IE: PostsController
        class_name.constantize # load app/**/* class definition
      end.compact
    end
  end
end