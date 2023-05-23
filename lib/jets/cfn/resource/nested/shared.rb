# Implements:
#
#   definition
#   template_filename
#
module Jets::Cfn::Resource::Nested
  class Shared < AppClass
    def initialize(options={})
      super
      @path = options[:path]
    end

    def definition
      logical_id = shared_logical_id
      definition = {
        logical_id => {
          Type: "AWS::CloudFormation::Stack",
          Properties: child_properties
        }
      }
      definition[logical_id][:DependsOn] = depends_on if depends_on
      definition
    end

    def child_properties
      props = {
        TemplateURL: template_url,
      }

      props[:Parameters] = Jets::Cfn::Params::Common.parameters # common child parameters
      # add depends on parameters
      depends_on.each do |dependency|
        dependency_outputs(dependency).each do |output|
          dependency_class = dependency.to_s.camelize
          props[:Parameters][output] = "!GetAtt #{dependency_class}.Outputs.#{output}"
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
      regexp = Regexp.new(".*#{Jets::Names.templates_folder}/shared-") # remove the shared
      shared_name = @path.sub(regexp, '').sub('.yml', '')
      shared_name.underscore.camelize
    end

    # IE: app/resource.rb => Resource
    # Returns Resource class object in the example
    def current_shared_class
      templates_prefix = "#{Jets::Names.templates_folder}/shared-"
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
  end
end
