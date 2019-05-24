# Implements:
#
#   compose
#   template_path
#
module Jets::Cfn::Builders
  class FunctionBuilder < BaseChildBuilder
    # compose is an interface method for Interface module
    def compose
      add_common_parameters
      add_functions
    end
  end
end
