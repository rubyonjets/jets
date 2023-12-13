module Jets::Cfn::Resource::Codebuild
  class Fleet < Jets::Cfn::Base
    def definition
      {
        CodebuildFleet: {
          Type: "AWS::CodeBuild::Fleet",
          Properties: props
        }
      }
    end

    def props
      {
        BaseCapacity: base_capacity,        # Integer
        ComputeType: compute_type,          # String
        EnvironmentType: environment_type   # String
        # Name: "",                         # String
        # Tags: "",                         # [ Tag, ... ]
      }
    end

    def base_capacity
      Jets.bootstrap.config.codebuild.fleet.base_capacity
    end

    def compute_type
      codebuild_properties[:Environment][:ComputeType]
    end

    def environment_type
      codebuild_properties[:Environment][:Type]
    end

    def outputs
      {
        "CodebuildFleet" => "!Ref CodebuildFleet"
      }
    end

    private

    def codebuild_properties
      project = Jets::Cfn::Resource::Codebuild::Project::Ec2.new
      project.properties
    end
    memoize :codebuild_properties
  end
end
