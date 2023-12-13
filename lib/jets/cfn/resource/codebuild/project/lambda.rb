module Jets::Cfn::Resource::Codebuild::Project
  class Lambda < Ec2
    def codebuild_logical_id
      "CodebuildLambda"
    end

    def project_name
      "#{Jets.project.namespace}-remote-lambda"
    end

    def compute_type
      config.codebuild.lambda.project.compute_type
    end
  end
end
