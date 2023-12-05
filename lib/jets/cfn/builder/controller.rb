class Jets::Cfn::Builder
  class Controller < Nested
    # interface method
    def compose
      add_common_parameters
      add_api_gateway_parameters
      add_functions
      add_resources
      add_outputs
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
