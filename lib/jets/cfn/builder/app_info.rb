class Jets::Cfn::Builder
  class AppInfo
    attr_reader :path
    def initialize(path)
      # "/tmp/jets_build/templates/proj-dev-posts-controller.yml"
      @path = path
    end

    def logical_id
      regexp = Regexp.new(".*#{project_name}-#{env}-")
      contoller_name = @path.sub(regexp, '').sub('.yml', '')
      contoller_name.underscore.camelize
    end

    def template_url
      # here's where it gets interesting with the bucket. The bucket will
      # need to exist for the child templates.  But wont be created until the stack
      # has been first launched.  We can create the bucket in a separate stack
      # And then grab it and then store it in a cache file.
      basename = File.basename(@path)
      "s3://[region].s3.amazonaws.com/[bucket]/cfn-templates/#{env}/#{basename}"
      # s3://boltops-jets/jets/cfn-templates/jets.zip
    end

    # Parameters that are common to all stacks
    def parameters
      {
        # YAML.dump converts it to a string
        # !GetAtt Base.Outputs.IamRole => "!GetAtt Base.Outputs.IamRole"
        # But post processing of the template fixes this
        IamRole: "!Ref IamRole",
        S3Bucket: "!Ref S3Bucket",
      }
    end

  private
    def project_name
      Jets::Project.project_name
    end

    def env
      Jets::Project.env
    end
  end
end