module Jets::Remote
  class Runner < Base
    cattr_reader :sig
    def run
      code_zip_and_upload

      command = @options[:command] || "deploy"
      command_args = if @options[:version] # jets rollback 8
        @options[:version]
      elsif @options[:templates] # jets build --templates or jets deploy --templates
        "--templates"
      end

      sig = Jets::Api::Sig.create(command: command, command_args: command_args, architecture: architecture)
      @@sig = sig[:token]
      @jets_go = sig[:jets_go]

      params = {
        buildspec_override: sig[:buildspec],
        environment_variables_override: environment_variables_override,
        project_name: project_name
      }
      fleet_override = Jets.bootstrap.config.codebuild.project.fleet_override
      if fleet_override
        params[:fleet_override] = {fleet_arn: fleet_override}
      end

      resp = codebuild.start_build(params)
      Jets::Api::Sig.update(sig[:id], build_id: resp.build.id)

      logger.info "Started remote run for #{command}"
      Jets::CLI::Tip.show(:remote_run, disable_howto: false)
      logger.info "Console Log Url:"
      logger.info codebuild_log_url(resp.build.id)

      tail_logs(resp.build.id)

      Download.new(command).download_built

      resp = codebuild.batch_get_builds(ids: [resp.build.id])
      success = resp.builds.first.build_status == "SUCCEEDED"
      exit 1 unless success
      success
    end

    def code_zip_and_upload
      code = Jets::Code.new(dummy: @options[:dummy])
      @app_src = code.zip_and_upload # s3_location
    end

    # Get architecture of codebuild image being used
    def architecture
      project = codebuild.batch_get_projects(names: [project_name]).projects.first
      image = project.environment.image # IE: aws/codebuild/amazonlinux-aarch64-lambda-standard:ruby3.2
      if image.include?("aarch64") || image.include?("arm64")
        "arm64"
      else
        "x86_64"
      end
    end

    def project_name
      stack_name = Jets::Names.parent_stack_name
      stack = cfn.describe_stacks(stack_name: stack_name).stacks.first
      logical_id = use_lambda_compute_type? ? "CodebuildLambda" : "Codebuild"
      stack.outputs.find { |o| o.output_key == logical_id }.output_value
    end
    memoize :project_name

    def use_lambda_compute_type?
      return true if Jets.bootstrap.config.infra
      return false unless Jets.bootstrap.config.codebuild.lambda.enable

      command = ARGV.first
      command == "ci" ||
        command == "waf" ||
        command == "dockerfile" ||
        ARGV.include?("--templates")
    end

    def environment_variables_override
      Jets::Cfn::Resource::Codebuild::Project::Env.new.pass_vars(
        JETS_APP_SRC: @app_src,
        JETS_GO: @jets_go,
        JETS_SIG: @@sig
      )
    end

    def tail_logs(build_id)
      Tailer.new(@options, build_id).run
    end

    private

    def codebuild_log_url(build_id)
      build_id = build_id.split(":").last
      region = Jets.aws.region
      "https://#{region}.console.aws.amazon.com/codesuite/codebuild/projects/#{project_name}/build/#{project_name}%3A#{build_id}/log"
    end
  end
end
