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
#   Jets::Klass.from_path("app/shared/functions/whatever.rb")
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
        class_name = load_anonymous_class(class_name, path)
        class_name.constantize # removed :: for anonymous classes
      else
        class_name.constantize # autoload
      end
    end

    # app/controllers/posts_controller.rb => PostsController
    def class_name(path)
      if path.include?("/shared/")
        path.sub(%r{.*app/shared/(.*?)/},'').sub(/\.rb$/,'').camelize
      else
        path.sub(%r{.*app/(.*?)/},'').sub(/\.rb$/,'').camelize
      end
    end

    APP_TYPES = %w[controller job rule authorizer]
    def from_task(task)
      class_name = task.class_name
      filename = class_name.underscore

      # Examples of filename: posts_controller, hard_job, security_rule, main_authorizer
      #   hello_function, hello
      type = filename.split('_').last
      type = "function" unless APP_TYPES.include?(type)

      path = "app/#{type.pluralize}/#{filename}.rb"
      from_path(path)
    end

    @@loaded_anonymous_classes = []
    def load_anonymous_class(class_name, path)
      parent_mod = modularize(class_name)

      constructor = Jets::Lambda::FunctionConstructor.new(path)
      # Dont load anonyomous class more than once to avoid these warnings:
      #   warning: already initialized constant Hello
      #   warning: previous definition of Hello was here
      unless @@loaded_anonymous_classes.include?(class_name)
        # use class_name as the variable name for prettier class name.
        leaf_class_name = class_name.split('::').last
        parent_mod.const_set(leaf_class_name, constructor.build)
        @@loaded_anonymous_classes << class_name
      end

      class_name
    end

    # Ensures the parent namespace modules are defined. Example:
    #
    #   modularize("Foo::Bar::Test")
    #   => Foo::Bar # is a now defined as a module if it wasnt before
    #
    # Also returns the parent module, so we can use it to do a const_set if needed. IE:
    #
    #   parent_mod = modularize("Foo::Bar::Test")
    #   parent_mod.const_set("Test")
    def modularize(class_name)
      leaves = []
      mods = class_name.split('::')[0..-2] # drop the last word
      # puts "mods: #{mods}"
      return Object if mods.empty?

      leaves = []
      mods.each do |leaf_mod|
        leaves += [leaf_mod]
        namespace = leaves.join('::')
        previous_namespace = leaves[0..-2].join('::')
        previous_namespace = "Object" if previous_namespace.empty?
        previous_namespace = previous_namespace.constantize
        previous_namespace.const_set(leaf_mod, Module.new) unless Object.const_defined?(namespace)
      end

      mods.join('::').constantize
    end

  end
end
