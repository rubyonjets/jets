# It builds a hello.lambda_function

module Jets::Lambda
  class FunctionConstructor
    def initialize(code_path)
      @code_path = code_path
    end

    # Returns an anonymous class that contains the methods defined in the
    # app/functions/hello.rb code
    #
    # Using Class.new which:
    # Creates a new anonymous (unnamed) class with the given superclass (or
    # Object if no parameter is given). You can give a class a name by
    # assigning the class object to a constant.
    # http://ruby-doc.org/core-2.1.1/Class.html#method-c-new
    #
    # So assigning the result of this to a constant makes for a prettier
    # class name. Example:
    #
    #   HelloFunction = FunctionConstructor.new(code_path)
    #   hello_function = HelloFunction.new
    def build
      code = IO.read(@code_path)
      function_klass = Class.new(Jets::Lambda::Function)
      function_klass.module_eval(code)
      function_klass # assign this to a Constant for a pretty class name
    end
  end
end

