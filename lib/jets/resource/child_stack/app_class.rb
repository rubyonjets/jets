# # Example of produced code:
# #
# #   map = Jets::Cfn::TemplateMappers::ControllerMapper.new(path, s3_bucket)
# #   map = Jets::Cfn::TemplateMappers::JobMapper.new(path, s3_bucket)
# #
# mapper_class_name = File.basename(path, '.yml').split('_').last
# mapper_class_name = mapper_class_name.classify
# mapper_class = "Jets::Cfn::TemplateMappers::#{mapper_class_name}Mapper".constantize # ControllerMapper or JobMapper
# map = mapper_class.new(path, @options[:s3_bucket])
#
# # map.logical_id example: PostsController, HardJob, Hello, HelloFunction
# add_resource(map.logical_id, "AWS::CloudFormation::Stack",
#   TemplateURL: map.template_url,
#   Parameters: map.parameters,
# )
module Jets::Resource::ChildStack
  class AppClass < Jets::Resource::Base
    def initialize(path, s3_bucket)
      @path = path
      @s3_bucket = s3_bucket
    end

    def definition
      logical_id = get_logical_id
      {
        logical_id => {
          type: "AWS::CloudFormation::Stack",
          properties: {
            template_url: template_url,
            parameters: parameters,
          }
        }
      }
    end

    def parameters
      {
        IamRole: "!GetAtt IamRole.Arn",
        S3Bucket: "!Ref S3Bucket",
      }
    end

    def outputs
      {
        logical_id => "!Ref #{logical_id}",
      }
    end

    # Dont name logical id because that is in Jets::Resource
    # map the path to a camelized logical_id. Example:
    #   /tmp/jets/demo/templates/demo-dev-2-posts_controller.yml to
    #   PostsController
    def get_logical_id
      regexp = Regexp.new(".*#{Jets.config.project_namespace}-")
      contoller_name = @path.sub(regexp, '').sub('.yml', '')
      contoller_name.underscore.camelize
    end

    def template_url
      "https://s3.amazonaws.com/#{@s3_bucket}/jets/cfn-templates/#{@path}"
    end
  end
end
