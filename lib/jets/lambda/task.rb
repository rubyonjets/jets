class Jets::Lambda::Task
  attr_accessor :class_name, :type
  attr_reader :meth, :properties, :lang
  def initialize(class_name, meth, options={})
    @class_name = class_name.to_s # use at EventsRuleMapper#full_task_name
    @meth = meth
    @options = options
    @type = options[:type] || get_type  # controller, job, or function
    @properties = options[:properties] || {}
    @lang = options[:lang] || :ruby
  end

  def name
    @meth
  end

  @@lang_exts = {
    ruby: '.rb',
    python: '.py',
    node: '.js',
  }
  def lang_ext
    @@lang_exts[@lang]
  end

  # The get_type method works for controller and job classes.
  #
  # Usually able to get the type from the class name. Examples:
  #
  #   PostsController => controller
  #   HardJob => job
  #
  # However, for function types, we are not able to get the type for multiple of
  # reasons.  First, function types are allowed to be named with or without
  # _function.  Examples:
  #
  #   path => class => type
  #   app/functions/hello.rb => Hello => function
  #   app/functions/hello_function.rb => HelloFunction => function
  #
  # The second reason is that functions are not regular ruby classes. Instead they
  # are anonymous classes created with Class.new.  When classes are created with
  # Class.new the method_added hook has "" (blank string) as the self class name.
  # We add the class_type to the task later on as we are constructing the class
  # as part of the Class.new logic.
  #
  # For controller and job standard ruby classes though it can easily be
  # determinated as part of initialization. So we get the type for convenience then.
  #
  # For anonymous function classes, we just set to nil and will later fix in
  # FunctionConstructor.
  #
  # Returns: "controller", "job" or nil
  def get_type
    unless @class_name.empty? # when anonymous class is created with Class.new
      @class_name.underscore.split('_').last # controller, job or rule
    end
  end

  def poly_handler_value(handler_function)
    "#{poly_handler_base_path}.#{handler_function}"
  end

  def poly_handler_path
    "#{poly_handler_base_path}#{@task.lang_ext}"
  end

  def poly_handler_base_path
    "handlers/#{@type.pluralize}/#{@class_name.underscore}/#{@meth}"
  end
end
