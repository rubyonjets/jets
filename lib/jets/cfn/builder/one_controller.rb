class Jets::Cfn::Builder
  class OneController < Nested
    def build?
      true
    end

    # interface method
    def compose
      add_one_function
      add_common_parameters
      add_api_gateway_parameters
      add_outputs
    end

    # interface method
    def template_path
      Jets::Names.one_controller_template_path
    end

    def add_one_function
      resource = Jets::Cfn::Resource::One::Function.new
      add_resource(resource)
      add_application_controller_iam_policy
      unless Jets::Router.no_routes?
        permission = Jets::Cfn::Resource::One::Permission.new
        add_resource(permission)
      end
    end

    def add_application_controller_iam_policy
      klass = ApplicationController
      return unless klass.build_class_iam?
      resource = Jets::Cfn::Resource::Iam::ClassRole.new(klass)
      add_resource(resource)
    end

    def add_outputs
      outputs = {}
      @template[:Resources].each do |logical_id, resource|
        next unless resource[:Type] == "AWS::Lambda::Function"
        outputs.merge!(logical_id => {
          Value: "!GetAtt #{logical_id}.Arn"
        })
      end
      @template[:Outputs] = outputs
    end

    def add_api_gateway_parameters
      return if Jets::Router.no_routes?
      add_parameter(:RestApi)
    end
  end
end
