module Jets::Cfn::Builder::Parent
  class Genesis
    extend Memoist
    include Jets::AwsServices
    include Jets::Cfn::Builder::Interface
    include Jets::Util::Logging

    def initialize(options)
      @options = options
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # interface method
    def compose
      clean
      add_description("Jets: #{Jets::VERSION}")
      add_resource(Jets::Cfn::Resource::S3::JetsBucket.new)

      # codebuild resources
      config = Jets.bootstrap.config # want bootstrap not deploy config here
      add_resource(Jets::Cfn::Resource::Codebuild::IamRole.new)
      unless config.infra
        add_resource(Jets::Cfn::Resource::Codebuild::Project::Ec2.new)
      end
      if config.infra || config.codebuild.lambda.enable
        add_resource(Jets::Cfn::Resource::Codebuild::Project::Lambda.new)
      end
      if config.codebuild.fleet.enable
        add_resource(Jets::Cfn::Resource::Codebuild::Fleet.new)
      end

      merge_existing_template! if @options[:bootstrap]
    end

    # interface method: Finale overrides
    def clean?
      @options[:bootstrap]
    end

    def clean
      return unless clean?
      templates_path = "#{Jets.build_root}/templates"
      logger.debug "Parent Genesis clean #{templates_path}"
      FileUtils.rm_rf(templates_path)
    end

    # interface method
    def template_path
      Jets::Names.parent_template_path
    end

    # Note: Tried concept of marking resources as a genesis resource as part of
    # add_resource but that approach cannot handle deletion of resources.
    # So we need a pre-defined list of genesis resources.
    class_attribute :genesis_resources
    self.genesis_resources = %w[S3Bucket Codebuild CodebuildRole CodebuildFleet]
    delegate :genesis_resources, to: :class

    # This is how cfn delta updates are achieved.
    def merge_existing_template!
      existing = existing_template
      return unless existing

      # Delete resources managed by the bootstrap genesis stack.
      existing["Resources"].delete_if { |k, v| genesis_resources.include?(k) }
      # Note: In case Outputs are all deleted by something else in the future
      # Finale stack does not delete outputs, it filters them.
      # Genesis resource outputs names should match the genesis resource logic id.
      outputs = existing["Outputs"]
      outputs&.delete_if { |k, v| genesis_resources.include?(k) }

      @template.deep_merge!(existing)
    end

    def existing_template
      stack_name = Jets::Names.parent_stack_name
      template_body = cfn.get_template(stack_name: stack_name).template_body
      # TODO: vs Jets::Util::Yamler
      Jets::Cfn::Stack::Yamler.load(template_body)
    rescue Aws::CloudFormation::Errors::ValidationError => e
      raise unless /does not exist/.match?(e.message)
    end
  end
end
