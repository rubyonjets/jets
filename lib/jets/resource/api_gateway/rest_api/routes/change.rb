# Detects route changes
class Jets::Resource::ApiGateway::RestApi::Routes
  class Change
    include Jets::AwsServices

    def changed?
      return false unless parent_stack_exists?

      MediaTypes.changed? || To.changed? || Variable.changed? || Page.changed? || ENV['JETS_REPLACE_API']
    end

    def parent_stack_exists?
      stack_exists?(Jets::Naming.parent_stack_name)
    end
  end
end
