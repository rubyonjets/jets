module Jets::Cfn::Params::Api
  class Resources < Base
    # interface method
    def build
      # For the nested ApiResources template defined in the parent template, we need
      # grab the parameters from the other paged ApiResources templates if not in
      # the current template.
      @template[:Parameters].keys.each do |key|
        key = key.to_sym
        case key.to_s
        when "RestApi"
          @params.merge!(key => "!GetAtt ApiGateway.Outputs.RestApi")
        when "RootResourceId"
          @params.merge!(key => "!GetAtt ApiGateway.Outputs.RootResourceId")
        else
          @params.merge!(key => "!GetAtt #{self.class.stack_logical_id(key)}.Outputs.#{key}")
        end
      end
    end

    class << self
      # IE: path: #{Jets.build_root}/templates/api-resources-1.yml"
      def stack_logical_id(parameter)
        Jets::Cfn::Template.lookup_logical_id("api-resources", parameter)
      end
    end
  end
end
