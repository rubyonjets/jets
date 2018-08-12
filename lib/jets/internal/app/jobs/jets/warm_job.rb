# Simple initial implementation of a prewarmer
class Jets::WarmJob < ApplicationJob
  rate '5 minutes'
  def preheat
    # load all classes
    # loop through all methods
    # make the special prewarm call to keep them warm
    Jets::Commands::Build.app_files.each do |path|
      # puts "path #{path}"
      class_path = path.sub(%r{.*app/\w+/},'').sub(/\.rb$/,'')
      class_name = class_path.classify
      klass = class_name.constantize # load app/**/* class definition
      # IE: PostsController

      klass.all_tasks.keys.each do |meth|
        underscored = class_name.underscore.gsub('/','-')
        function_name = "#{underscored}-#{meth}"
        # puts "function_name #{function_name}"
        Jets::Commands::Call.new(function_name, '{"_prewarm": "1"}').run
      end
    end
  end
end
