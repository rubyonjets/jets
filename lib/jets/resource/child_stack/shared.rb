# Implements:
#
#   definition
#   template_filename
#
module Jets::Resource::ChildStack
  class Shared < AppClass
    def initialize(s3_bucket, options={})
      super
      @path = options[:path]
    end

    def definition
      {
        shared_logical_id => {
          type: "AWS::CloudFormation::Stack",
          properties: {
            template_url: template_url,
          }
        }
      }
    end

    # map the path to a camelized logical_id. Example:
    #   /tmp/jets/demo/templates/demo-dev-2-shared-resources.yml to
    #   PostsController
    def shared_logical_id
      regexp = Regexp.new(".*#{Jets.config.project_namespace}-") # keep the shared
      shared_name = @path.sub(regexp, '').sub('.yml', '')
      shared_name.underscore.camelize
    end

    def current_app_class
      templates_prefix = "#{Jets::Naming.template_path_prefix}-shared-"
      @path.sub(templates_prefix, '')
        .sub(/\.yml$/,'')
        .gsub('-','/')
        .classify
    end

    def template_filename
      "#{Jets.config.project_namespace}-shared-#{current_app_class.underscore}.yml"
    end
  end
end
