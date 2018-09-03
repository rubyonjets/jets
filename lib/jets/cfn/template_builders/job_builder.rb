class Jets::Cfn::TemplateBuilders
  class JobBuilder < BaseChildBuilder
    def compose
      add_common_parameters
      add_functions
      add_associated_resources
    end
  end
end
