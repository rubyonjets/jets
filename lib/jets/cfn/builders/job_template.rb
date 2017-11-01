class Jets::Cfn::Builders
  class JobTemplate < ChildTemplate
    def compose
      add_common_parameters
      add_function(:perform)
    end
  end
end
