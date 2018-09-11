class Jets::Cfn::Builders
  class SharedBuilder < BaseChildBuilder
    def compose
      add_shared_resources
    end

    def add_shared_resources
      Jets::SharedResource.resources.each do |resource|
        add_resource(resource)
        add_outputs(resource.outputs)
      end
    end

    # template_path is an interface method for Interface module
    def template_path
      Jets::Naming.shared_template_path(@app_class)
    end
  end
end
