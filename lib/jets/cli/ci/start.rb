class Jets::CLI::Ci
  class Start < Base
    def run
      are_you_sure?

      params = {project_name: project_name}
      source_version = @options[:branch]
      params[:source_version] = source_version if source_version # when nil. uses branch configured on CodeBuild project settings
      params[:secondary_sources_version_override] = secondary_sources_version_override if secondary_sources_version_override # when nil. uses branch configured on CodeBuild project settings
      params[:environment_variables_override] = environment_variables_override if @options[:env_vars]
      params.merge!(@options[:overrides]) if @options[:overrides]
      branch_info
      params[:buildspec_override] = buildspec_override
      log.debug("params: #{params}")
      resp = start_build(params)

      log.info "Build started for #{project_name}"
      show_console_log_url(resp.build.id)
      tail_logs(resp.build.id)

      resp = codebuild.batch_get_builds(ids: [resp.build.id])
      success = resp.builds.first.build_status == "SUCCEEDED"
      exit 1 unless success
      success
    end

    def start_build(params)
      codebuild.start_build(params)
    rescue Aws::CodeBuild::Errors::ResourceNotFoundException => e
      log.error "Error: #{e.message}".color(:red)
      log.error <<~EOL
        AWS CodeBuild Project #{project_name} not found. Are you sure it exists?
        Maybe double-check your AWS config settings
      EOL
      exit 1
    end

    def buildspec_override
      return unless @options[:buildspec_override]
      IO.read(@options[:buildspec_override])
    end

    def tail_logs(build_id)
      Tailer.new(@options, build_id).run
    end

    def environment_variables_override
      @options[:env_vars].map do |s|
        k, v = s.split("=")
        ssm = false
        if /^ssm:(.*)/ =~ v
          v = $1
          ssm = true
        end

        {
          name: k,
          value: v,
          type: ssm ? "PARAMETER_STORE" : "PLAINTEXT"
        }
      end
    end

    def branch_info
      if @options[:branch]
        log.info "Branch: #{@options[:branch]}"
      end
      if @options[:secondary_branches]
        log.info "Branches: #{@options[:secondary_branches]}"
      end
    end

    # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/CodeBuild/Client.html#start_build-instance_method
    # Map Hash to secondary_sources_version_override Structure. IE:
    # From: {Main: "feature1"}
    # To: [{source_identifier: "Main", source_version: "feature"}]
    def secondary_sources_version_override
      secondary_branches = @options[:secondary_branches]
      return unless secondary_branches
      secondary_branches.map do |id, version|
        {source_identifier: id, source_version: version}
      end
    end

    def are_you_sure?
      message = "Will start build and deploy #{project_name.color(:green)}\n"
      message << "#{git_dirty_message}\n" if git_dirty?
      sure? message
    end

    def git_dirty_message
      if git_dirty?
        <<~EOL.strip
          Warning: Git is dirty. The CI build will not include the latest changes.
          If you want to include the latest changes, please commit and push them first.
        EOL
      elsif !git_changes_pushed?
        <<~EOL.strip
          Warning: The latest changes have not been pushed to the remote repository.
          If you want to include the latest changes, please push them first.
        EOL
      end
    end

    def git_changes_pushed?
      current_branch = `git branch --show-current`.strip
      local_commit = `git rev-parse #{current_branch}`.strip
      remote_commit = `git rev-parse origin/#{current_branch}`.strip
      local_commit == remote_commit
    end

    def git_dirty_note
      "(git is dirty)" if git_dirty?
    end

    def git_dirty?
      `git status --porcelain`.strip != ""
    end
    memoize :git_dirty?
  end
end
