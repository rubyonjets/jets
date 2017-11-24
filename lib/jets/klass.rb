class Jets::Klass
  class << self
    # Loading a class can usually be loaded via .constantize.
    # However app/functions files are use to create anonymous ruby classes
    # and anonymous classes cannot be loaded via .constantize which relies on
    # autoloading.
    #
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
      type = if filename =~ /_controller$/
               "controller"
             elsif filename =~ /_job$/
               "job"
             else # simple function
               "function"
             end

      path = "app/#{type.pluralize}/#{filename}.rb"
      from_path(path)
    end

    @@loaded_anonymous_classes = []
    def load_anonymous_class(class_name, path)
      constructor = Jets::Lambda::FunctionConstructor.new(path)
      # use class_name as the variable name for prettier class name.
      unless @@loaded_anonymous_classes.include?(class_name)
        # dont refined to avoid warnings:
        #   warning: already initialized constant Hello
        #   warning: previous definition of Hello was here
        Object.const_set(class_name, constructor.build)
        @@loaded_anonymous_classes << class_name
      end
    end

  end
end
