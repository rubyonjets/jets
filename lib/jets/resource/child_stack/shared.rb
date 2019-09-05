# Implements:
#
#   definition
#   template_filename
#
module Jets::Resource::ChildStack
  class Shared < AppClass
    include CommonParameters

    def initialize(s3_bucket, options={})
      super
      @path = options[:path]
    end

    def definition
      logical_id = shared_logical_id
      definition = {
        logical_id => {
          type: "AWS::CloudFormation::Stack",
          properties: child_properties
        }
      }
      definition[logical_id][:depends_on] = depends_on if depends_on
      definition
    end

    def child_properties
      props = {
        template_url: template_url,
      }

      props[:parameters] = common_parameters # common child parameters
      # add depends on parameters
      depends_on.each do |dependency|
        dependency_outputs(dependency).each do |output|
          dependency_class = dependency.to_s.camelize
          props[:parameters][output] = "!GetAtt #{dependency_class}.Outputs.#{output}"
        end
      end if depends_on

      props
    end

    # Returns output keys associated with the stack.  They are the resource logical ids.
    def dependency_outputs(dependency)
      dependency.to_s.camelize.constantize.output_keys
    end

    def depends_on
      return unless current_shared_class.depends_on
      current_shared_class.depends_on.map { |x| x.to_s.camelize }
    end

    # map the path to a camelized logical_id. Example:
    #   /tmp/jets/demo/templates/demo-dev-2-shared-resources.yml to
    #   PostsController
    def shared_logical_id
      regexp = Regexp.new(".*#{Jets.config.project_namespace}-shared-") # remove the shared
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
        .camelize
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
