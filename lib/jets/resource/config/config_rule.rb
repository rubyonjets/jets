module Jets::Resource::Config
  class ConfigRule < Jets::Resource::Base
    def initialize(app_class, meth, props={})
      @app_class = app_class.to_s
      @meth = meth
      @props = props # associated_properties from dsl.rb
    end

    def definition
      base = {
        config_rule_logical_id => {
          type: "AWS::Config::ConfigRule",
          properties: definition_properties
        }
      }

      # Explicitly set depends_on to help with CloudFormation random race condition.
      # Seems to be a new CloudFormation and AWS Config resource issue.
      if definition_properties[:source][:owner] == 'CUSTOM_LAMBDA'
        base[config_rule_logical_id][:depends_on] = "{namespace}Permission"
      end

      base
    end

    # Do not name this method properties, that is a computed method of `Jets::Resource::Base`
    def definition_properties
      {
        config_rule_name: config_rule_name,
        source: {
          owner: "CUSTOM_LAMBDA",
          source_identifier: "!GetAtt {namespace}LambdaFunction.Arn",
          source_details: [
            {
              event_source: "aws.config",
              message_type: "ConfigurationItemChangeNotification"
            },
            {
              event_source: "aws.config",
              message_type: "OversizedConfigurationItemChangeNotification"
            }
          ]
        },
      }.deep_merge(@props)
    end

    def config_rule_logical_id
      "{namespace}_config_rule"
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
        Jets.config.project_namespace
      else
        namespace
      end
    end
  end
end