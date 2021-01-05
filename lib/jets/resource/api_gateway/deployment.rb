module Jets::Resource::ApiGateway
  class Deployment < Jets::Resource::Base
    def definition
      {
        deployment_logical_id => {
          type: "AWS::ApiGateway::Deployment",
          properties: {
            description: "Version #{timestamp} deployed by jets",
            rest_api_id: "!Ref #{RestApi.logical_id}",
            stage_name: stage_name,
          }
        }
      }
    end

    def parameters
      p = {
        "GemLayer" => "GemLayer",
        "IamRole" => "IamRole",
        "RestApi" => "RestApi",
        "S3Bucket" => "S3Bucket",
      }
      p[:DomainName] = "DomainName" if Jets.custom_domain?
      p[:BasePath] = "BasePath" unless Jets.config.domain.base_path.nil?
      p
    end

    def outputs(internal=false)
      rest_api = internal ? RestApi.internal_logical_id : "RestApi"
      {
        "RestApiUrl" => "!Sub 'https://${#{rest_api}}.execute-api.${AWS::Region}.amazonaws.com/#{stage_name}/'",
      }
    end

    def depends_on
      expression = "#{Jets::Naming.template_path_prefix}-*_controller*"
      controller_logical_ids = []
      Dir.glob(expression).each do |path|
        next unless File.file?(path)

        regexp = Regexp.new(".*#{Jets.config.project_namespace}-")
        controller_name = path.sub(regexp, '').sub('.yml', '')
        # map the path to a camelized logical_id. Example:
        #   /tmp/jets/demo/templates/demo-dev-2-posts_controller.yml to
        #   PostsController
        controller_logical_id = controller_name.underscore.camelize

        controller_logical_ids << controller_logical_id
      end
      controller_logical_ids
    end

    # stage_name: dev, dev-1, dev-2, etc
    def stage_name
      self.class.stage_name
    end

    def self.stage_name
      # Stage name only allows a-zA-Z0-9_
      [Jets.config.short_env, Jets.config.env_extra].compact.join('_').gsub('-','_')
    end

    def timestamp
      self.class.timestamp
    end

    @@timestamp = nil
    def self.timestamp
      @@timestamp ||= Time.now.strftime("%Y%m%d%H%M%S")
    end

    def deployment_logical_id
      self.class.logical_id.underscore
    end

    def self.logical_id
      "ApiDeployment#{timestamp}"
    end
  end
end