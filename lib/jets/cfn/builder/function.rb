class Jets::Cfn::Builder
  class Function < Nested
    # interface method
    def compose
      add_common_parameters
      add_functions
    end
  end
end
