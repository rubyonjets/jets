class Jets::Cfn::Builder
  class Job < Nested
    # interface method
    def compose
      add_common_parameters
      add_functions
      add_resources
    end
  end
end
