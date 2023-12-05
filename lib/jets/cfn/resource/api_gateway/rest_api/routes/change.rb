# Detects route changes
class Jets::Cfn::Resource::ApiGateway::RestApi::Routes
  class Change
    include Jets::AwsServices

    def changed?
      return false unless parent_stack_exists?
      return true if reset?

      # Note: Variable.changed? will likely always true in one_apigw_method_for_all_routes mode
      # since parent variables are allowed to vary in Jets v5.
      if Jets.config.cfn.build.routes == "one_apigw_method_for_all_routes"
        MediaTypes.changed? || To.changed?
      else
        MediaTypes.changed? || To.changed? || Variable.changed? || Page.changed?
      end
    end

    def reset?
      ENV['JETS_RESET'] || ENV['JETS_API_REPLACE'] || ENV['JETS_REPLACE_API']
    end

    def parent_stack_exists?
      stack_exists?(Jets::Names.parent_stack_name)
    end
  end
end
