module Jets::Cfn::Resource::Nested
  class AppClass < Base
    def initialize(options={})
      super
      @path = options[:path]
    end

    # interface method
    def definition
      logical_id = app_logical_id
      defintion = {
        logical_id => {
          Type: "AWS::CloudFormation::Stack",
          Properties: {
            TemplateURL: template_url,
            Parameters: parameters,
          }
        }
      }
      defintion[logical_id][:DependsOn] = depends.stack_list if depends
      defintion
    end

    def depends
      return if all_depends_on.empty?
      Jets::Stack::Depends.new(all_depends_on)
    end
    memoize :depends

    # Always returns an Array, could be empty
    def all_depends_on
      depends_on = current_app_class.depends_on || [] # contains Depends::Items
      stagger_depends_on = @stagger_depends_on  || [] # contains Depends::Items
      depends_on + stagger_depends_on
    end

    # For staggering. We're abusing depends_on to slow down the update rate.
    #
    # For this type of depends_on, there are no template parameters or outputs. To use the normal depends at we would
    # have to make app classes adhere to what Jets::Stack::Depends requires.  This is mainly dependency_outputs and
    # output_keys for each class right now.  It would not be that difficult but is not needed. So we create the
    # Jets::Stack::Depends::Item objects directly.
    def add_stagger_depends_on(stacks)
      stack_names = stacks.map { |s| s.current_app_class.to_s.underscore }
      items = stack_names.map { |name| Jets::Stack::Depends::Item.new(name) }
      @stagger_depends_on ||= []
      @stagger_depends_on += items.flatten
    end

    def parameters
      params = Jets::Cfn::Params::Common.parameters
      params.merge!(controller_params) if controller?
      params.merge!(depends.params) if depends
      params
    end

    def controller_params
      return {} if Jets::Router.no_routes?

      params = {
        RestApi: "!GetAtt ApiGateway.Outputs.RestApi",
      }

      template_path = @path
      template = Jets::Cfn::Template.load_file(template_path)
      template[:Parameters].each do |p,data|
        case p
        when /Authorizer$/ # AWS::ApiGateway::Authorizer in authorizers templates. IE: demo-dev-authorizers.yml
          # Description contains metadata to get the Authorizer logical id
          params[p] = "!GetAtt #{authorizer_output(data[:Description])}"
        end
      end
      params
    end

    def authorizer_output(desc)
      authorizer_stack, authorizer_logical_id = desc.split('.')
      # IE: MainAuthorizer.Outputs.ProtectAuthorizer
      "#{authorizer_stack}.Outputs.#{authorizer_logical_id}"
    end

    def outputs
      if controller? or job?
        {}
      else
        super # { logical_id => "!Ref #{logical_id}" } in base.rb
      end
    end

    def controller?
      @path.include?('_controller.yml')
    end

    def job?
      @path.include?('_job.yml')
    end

    def current_app_class
      templates_prefix = "#{Jets::Names.templates_folder}/app-"
      @path.sub(templates_prefix, '')
        .sub(/\.yml$/,'')
        .gsub('-','/')
        .camelize
        .constantize
    end

    # map the path to a camelized logical_id. Example:
    #   /tmp/jets/demo/templates/demo-dev-2-posts_controller.yml to
    #   PostsController
    def app_logical_id
      regexp = Regexp.new(".*#{Jets::Names.templates_folder}/app-")
      controller_name = @path.sub(regexp, '').sub('.yml', '')
      controller_name.underscore.camelize
    end
  end
end