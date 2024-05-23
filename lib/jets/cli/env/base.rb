class Jets::CLI::Env
  class Base < Jets::CLI::Base
    include Jets::CLI::Lambda::Checks
    include Jets::Util::Truthy

    def initialize(options = {})
      super
      check_deployed!
      function_name = Jets::CLI::Lambda::Lookup.function(options[:function])
      @lambda_function = Jets::CLI::Lambda::Function.new(function_name)
    end
  end
end
