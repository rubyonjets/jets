class Jets::Lambda::Task
  attr_accessor :class_name, :type
  attr_reader :meth, :properties, :iam_policy, :managed_iam_policy, :lang, :associated_resources
  def initialize(class_name, meth, options={})
    @class_name = class_name.to_s
    @meth = meth
    @options = options
    @type = options[:type] || get_type  # controller, job, or function
    @properties = options[:properties] || {}
    @iam_policy = options[:iam_policy]
    @managed_iam_policy = options[:managed_iam_policy]
    @lang = options[:lang] || :ruby
    @associated_resources = options[:associated_resources] || {}
    @replacements = options[:replacements] || {} # added to baseline replacements
  end

  def name
    @meth
  end

  def public_meth?
    # For anonymous classes (app/functions/hello.rb) the class name will be blank.
    # These types of classes are treated specially and has only one handler method
    # that is registered. So we know it is public.
    return true if @class_name.nil? || @class_name == ''

    # Consider all polymorphic methods public for now
    return true if @lang != :ruby

    klass = @class_name.constantize
    public_methods = klass.public_instance_methods
    public_methods.include?(meth.to_sym)
  end

  def build_function_iam?
    !!(@iam_policy || @managed_iam_policy)
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

  def full_handler(handler_function)
    "#{handler_base}.#{handler_function}"
  end

  def handler_path
    "#{handler_base}#{lang_ext}"
  end

  def handler_base
    base = "handlers/#{@type.pluralize}/#{@class_name.underscore}"
    base += "/#{@lang}" if @lang != :ruby
    base += "/#{@meth}"
  end

  def poly_src_path
    handler_path.sub("handlers/", "app/")
  end

  def replacements
    # Merge in the custom replacements specific to each app class: ConfigRule, Job, etc.
    baseline_replacements.merge(@replacements)
  end

  def baseline_replacements
    {
      # camelized because used in not just keys but common used in values
      namespace: @meth.to_s.camelize,
    }
  end
end
