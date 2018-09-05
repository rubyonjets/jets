class Jets::Cfn::Builders
  class FunctionBuilder < BaseChildBuilder
    # compose is an interface method for Interface module
    def compose
      add_common_parameters
      add_functions
    end

    # For function stacks, ensure there's a _function.yml at the end of the
    # template_path name for easy identification.
    def template_path
      path = super
      unless path.include?("function.yml")
        path = path.sub(".yml", "_function.yml")
      end
      path
    end
  end
end
