class Jets::Cfn::TemplateBuilders
  class FunctionBuilder < BaseChildBuilder
    # compose is an interface method for Interface module
    def compose
      add_common_parameters
      add_functions
    end

    # For function stacks, ensure there's a _function.rb at the end.
    # This is because we allow users to defined app/functions without
    # the _function.rb at the end.
    # There is an off chance of this edge case:
    #
    #   app/functions/hello_function.rb
    #   app/functions/hello.rb
    #
    # We wont worry about that.
    def template_path
      path = super
      unless path.include?("function.yml")
        path = path.sub(".yml", "_function.yml")
      end
      path
    end

  end
end
