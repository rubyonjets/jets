module Jets::Cfn::Resource::Config
  class ConfigRule < Jets::Cfn::Base
    def initialize(app_class, meth, props={})
      @app_class = app_class.to_s
      @meth = meth
      @props = props # associated_properties from dsl.rb
    end

    def definition
      base = {
        config_rule_logical_id => {
          Type: "AWS::Config::ConfigRule",
          Properties: definition_properties
        }
      }

      # Explicitly set depends_on to help with CloudFormation random race condition.
      # Seems to be a new CloudFormation and AWS Config resource issue.
      if definition_properties[:Source][:Owner] == 'CUSTOM_LAMBDA'
        base[config_rule_logical_id][:DependsOn] = "{namespace}Permission"
      end

      base
    end

    # Do not name this method properties, that is a computed method of `Jets::Cfn::Resource`
    def definition_properties
      {
        ConfigRuleName: config_rule_name,
        Source: {
          Owner: "CUSTOM_LAMBDA",
          SourceIdentifier: "!GetAtt {namespace}LambdaFunction.Arn",
          SourceDetails: [
            {
              EventSource: "aws.config",
              MessageType: "ConfigurationItemChangeNotification"
            },
            {
              EventSource: "aws.config",
              MessageType: "OversizedConfigurationItemChangeNotification"
            }
          ]
        },
      }.deep_merge(@props)
    end

    def config_rule_logical_id
      "{namespace}ConfigRule"
    end

    def config_rule_name
      app_class = @app_class.underscore.gsub(/_rule$/,'')
      ns = namespace
      ns = nil if ns == false # for compact
      [ns, "#{app_class}_#{@meth}"].compact.join('_').dasherize
    end

    def namespace
      namespace = nil
      klass = @app_class.constantize
      while klass != Jets::Lambda::Functions
        namespace = klass.rule_namespace
        break if namespace or namespace == false
        klass = klass.superclass
      end

      if namespace.nil?
        Jets.project_namespace
      else
        namespace
      end
    end
  end
end