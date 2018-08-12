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

    def warm(function_name)
      Jets::Commands::Call.new(function_name, '{"_prewarm": "1"}', @options).run unless ENV['TEST']
    end

    # loop through all methods fo each class
    # make the special prewarm call to keep them warm
    def warm_all
      threads = []
      all_functions.each do |function_name|
        threads << Thread.new do
          warm(function_name)
        end
      end
      threads.each { |t| t.join }
      # return the funciton names so we can see in the Lambda console
      # the functions being prewarmed
      all_functions
    end

    # Returns:
    #   [
    #     "posts_controller-index",
    #     "posts_controller-show",
    #     ...
    #   ]
    def all_functions
      classes.map do |klass|
        klass.all_tasks.keys.map do |meth|
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