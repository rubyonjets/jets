# Builds an anonymous class that represents a single Lambda function from code
# in app/functions.
#
# The build method returns an anonymous class using Class.new that contains
# the methods defined in the app/functions/hello.rb code.
#
# Ruby Class.new docs:
#
# Creates a new anonymous (unnamed) class with the given superclass (or
# Object if no parameter is given). You can give a class a name by
# assigning the class object to a constant.
# http://ruby-doc.org/core-2.1.1/Class.html#method-c-new
#
# So assigning the result of build to a constant makes for a prettier
# class name. Example:
#
#   constructor = FunctionConstructor.new(code_path)
#   HelloFunction = constructor.build
#
# The class name will be HelloFunction instead of (anonymous). Then usage would
# be:
#
#   hello_function = HelloFunction.new
#   hello_function(hello_function.handler, event, context)
#
# Or call with the process class method:
#
#   HelloFunction.process(event, context, "world")
module Jets::Lambda
  class FunctionConstructor
    def initialize(code_path)
      @code_path = "#{Jets.root}/#{code_path}"
    end

    def build
      code = IO.read(@code_path)
      function_klass = Class.new(Jets::Lambda::Function)
      function_klass.module_eval(code, @code_path)
      adjust_tasks(function_klass)
      function_klass # assign this to a Constant for a pretty class name
    end

    # For anonymous classes method_added during task registration contains ""
    # for the class name.  We adjust it here.
    def adjust_tasks(klass)
      class_name = @code_path.to_s.sub(/.*\/functions\//,'').sub(/\.rb$/, '')
      class_name = class_name.camelize
      klass.tasks.each do |task|
        task.class_name = class_name
        task.type = "function"
      end
    end
  end
end

