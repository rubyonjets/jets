module Jets::Cfn::Resource::Codebuild::Project
  class Ec2 < Base
    def definition
      {
        codebuild_logical_id => {
          Type: "AWS::CodeBuild::Project",
          Properties: finalize_properties(props)
        }
      }
    end

    # Do not name this method properties as that's a computed method
    def props
      {
        Name: project_name,
        Artifacts: {
          Type: "NO_ARTIFACTS"
        },
        Environment: environment,
        Source: {
          Type: "NO_SOURCE",
          BuildSpec: build_spec
        },
        ServiceRole: "!Ref CodebuildRole",
        LogsConfig: {
          CloudWatchLogs: {
            Status: "ENABLED"
          }
        }
      }
    end

    # Only supported for EC2 compute type. Lambda compute type does not support.
    def timeout_in_minutes
      config.codebuild.project.timeout || config.codebuild.project.timeout_in_minutes
    end

    # Certain properties are not supported for certain Compute Types
    # We set this at the end based on the final Environment Type
    #
    # PrivilegedMode: Only supported for non-LAMBDA environment types
    # Cache: non-LAMBDA environment types
    #
    #   CREATE_FAILED AWS::CodeBuild::Project Codebuild Cannot specify timeoutInMinutes for lambda compute
    #   TimeoutInMinutes: 20, # TODO: make this configurable
    #   CREATE_FAILED AWS::CodeBuild::Project
    #   Codebuild Cannot specify cache for lambda compute. Error Code: InvalidInputException
    #
    # PrivilegedMode: true, # Note: does not seem to be actually needed for docker support
    # When using PrivilegedMode for ARM_LAMBDA_CONTAINER it'll error though.
    # Not officially supporting ARM_LAMBDA_CONTAINER when packaging code anyway.
    # Just noting for posterity.
    def finalize_properties(props)
      if environment[:Type].include?("LAMBDA")
        props[:Cache] = {
          Type: "NO_CACHE"
        }
        props[:Environment][:PrivilegedMode] = false
      else
        props[:Cache] = {
          Type: "LOCAL",
          Modes: ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_CUSTOM_CACHE"]
        }
        props[:TimeoutInMinutes] = timeout_in_minutes # not supported for lambda compute
        props[:Environment][:PrivilegedMode] = true
      end

      if config.codebuild.fleet.enable
        props[:Environment][:Fleet] = {
          FleetArn: "!Ref CodebuildFleet"
        }
      end

      props
    end

    def build_spec
      <<~EOL
        version: 0.2

        phases:
          build:
            commands:
               - uname -a
      EOL
    end

    # https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html
    def environment
      env = compute_type
      env.deep_merge!(config.codebuild.project.environment)
      env.deep_merge!(EnvironmentVariables: environment_variables) if environment_variables
      # sort for correct diffing. Deploy#changed? checks the template body diff
      env[:EnvironmentVariables].sort_by! { |h| h[:Name] }
      env
    end
    memoize :environment

    def environment_variables
      Env.new.vars
    end

    def outputs
      {
        codebuild_logical_id => "!Ref #{codebuild_logical_id}"
      }
    end

    # interface method
    def codebuild_logical_id
      "Codebuild"
    end

    # interface method
    def project_name
      "#{Jets.project.namespace}-remote"
    end

    # interface method
    def compute_type
      # Note: PrivilegedMode is set at the end in finalize_properties based on the final Type
      config.codebuild.project.compute_type
    end
  end
end
