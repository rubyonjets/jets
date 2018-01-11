# Loading a class can usually be loaded via .constantize.
# But app/functions files are anonymous ruby classes created with
# Class.new.  Anonymous classes cannot be loaded via .constantize and
# go through standard autoloading.
#
# Jets::Klass provides a way to load app classes in app/controllers, app/jobs,
# app/functions in a consistent way without having to worry about the anonymous
# class loading quirk. Classes that are not anonymously defined like controllers
# and jobs are loaded via autoloading with .constantize. Anonymously defined
# classes like functions are loaded via Object.const_set.
#
# Examples:
#
#   Jets::Klass.from_path("app/controllers/posts_controller.rb")
#   Jets::Klass.from_path("app/jobs/hard_job.rb")
#   Jets::Klass.from_path("app/functions/hello.rb")
#   Jets::Klass.from_path("app/functions/hello_function.rb")
#
#   Jets::Klass.from_task(task)
#
# The from_task method takes a Jets::Lambda::Task as an argument and is useful
# for the CloudFormation child stack generation there the registered task info
# is available but the path info is now.
class Jets::Klass
  class << self
    # from_path allows us to load any app classes in consistent way for
    # app/controllers, app/jobs, and app/functions.
    def from_path(path)
      class_name = class_name(path)

      if path.include?("/functions/") # simple function
        load_anonymous_class(class_name, path)
      end

      class_name.constantize # autoload or nothing if load_anonymous_class called
    end

    # app/controllers/posts_controller.rb => PostsController
    def class_name(path)
      path.sub(%r{.*app\/(.*?)/},'').sub(/\.rb$/,'').classify
    end

    def from_task(task)
      class_name = task.class_name
      filename = class_name.underscore

      # Examples of filename: posts_controller, hard_job, security_rule,
      #   hello_function, hello
      valid_types = %w[controller job rule]
      type = filename.split('_').last
      type = "function" unless valid_types.include?(type)

      path = "app/#{type.pluralize}/#{filename}.rb"
      from_path(path)
    end

    @@loaded_anonymous_classes = []
    def load_anonymous_class(class_name, path)
      constructor = Jets::Lambda::FunctionConstructor.new(path)
      # Dont load anonyomous class more than once to avoid these warnings:
      #   warning: already initialized constant Hello
      #   warning: previous definition of Hello was here
      unless @@loaded_anonymous_classes.include?(class_name)
        # use class_name as the variable name for prettier class name.
        Object.const_set(class_name, constructor.build)
        @@loaded_anonymous_classes << class_name
      end
    end

  end
end
