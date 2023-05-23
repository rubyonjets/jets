module Jets::Cfn::Resource::ApiGateway
  class Deployment < Jets::Cfn::Base
    def definition
      {
        deployment_logical_id => {
          Type: "AWS::ApiGateway::Deployment",
          Properties: {
            Description: "Version #{timestamp} deployed by jets",
            RestApiId: "!Ref #{RestApi.logical_id}",
            StageName: stage_name,
          }
        }
      }
    end

    def parameters
      {
        RestApi: "RestApi",
      }
    end

    def outputs(internal=false)
      rest_api = internal ? RestApi.internal_logical_id : "RestApi"
      {
        RestApiUrl: "!Sub 'https://${#{rest_api}}.execute-api.${AWS::Region}.amazonaws.com/#{stage_name}/'",
      }
    end

    def depends_on
      expression = "#{Jets::Names.templates_folder}/*_controller*"
      controller_logical_ids = []
      Dir.glob(expression).each do |path|
        next unless File.file?(path)

        controller_name = path.sub("#{Jets::Names.templates_folder}/", '').sub('.yml', '')
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
      [Jets.short_env, Jets.extra].compact.join('_').gsub('-','_')
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