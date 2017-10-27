class Jets::Cfn::Builder
  class BaseInfo
    def logical_id
      "Base"
    end

    def template_url
      # here's where it gets interesting with the bucket. The bucket will
      # need to exist for the child templates.  But wont be created until the stack
      # has been first launched.  We can create the bucket in a separate stack
      # And then grab it and then store it in a cache file.
      basename = "#{project_name}-#{env}-base.yml"
      "s3://[region].s3.amazonaws.com/[bucket]/cfn-templates/#{env}/#{basename}"
      # s3://boltops-jets/jets/cfn-templates/jets.zip
    end

    # Parameters that are common to all stacks
    def parameters
      {
        S3Bucket: "boltops-jets",
        IamRole: "arn:aws:iam::160619113767:role/service-role/lambda-test-harness"
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