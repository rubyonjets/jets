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

    # IE: app/resource.rb => Resource
    # Returns Resource class object in the example
    def current_shared_class
      templates_prefix = "#{Jets::Naming.template_path_prefix}-shared-"
      @path.sub(templates_prefix, '')
        .sub(/\.yml$/,'')
        .gsub('-','/')
        .classify
        .constantize # returns actual class
    end

    # Tells us if there are any resources defined in the shared class.
    #
    # Returns: Boolean
    def resources?
      current_shared_class.build?
    end

    def template_filename
      "#{Jets.config.project_namespace}-shared-#{current_shared_class.to_s.underscore}.yml"
    end
  end
end
