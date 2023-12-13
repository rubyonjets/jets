class Jets::CLI::Ci
  class Base < Jets::CLI::Base
    def stack_name
      "#{Jets.project.namespace}-ci"
    end
    alias_method :project_name, :stack_name

    def run_with_exception_handling
      yield
    rescue Aws::CodeBuild::Errors::ResourceNotFoundException => e
      puts "ERROR: #{e.class}: #{e.message}".color(:red)
      puts "CodeBuild project #{project_name} not found."
    rescue Aws::CodeBuild::Errors::InvalidInputException => e
      puts "ERROR: #{e.class}: #{e.message}".color(:red)
    end

    def stop_build
      build = codebuild.batch_get_builds(ids: [build_id]).builds.first
      if build.build_status == "IN_PROGRESS"
        codebuild.stop_build(id: build_id)
        true
      else
        log.info "Not in progress. Status is #{build.build_status}. Cannot stop: #{build_id}"
        false
      end
    end

    def build_id
      return @options[:build_id] if @options[:build_id]
      find_build
    end
    memoize :build_id

    def find_build
      resp = codebuild.list_builds_for_project(project_name: project_name)
      resp.ids.first # most recent build_id
    rescue Aws::CodeBuild::Errors::ResourceNotFoundException => e
      logger.error "ERROR: #{e.class} #{e.message}".color(:red)
      exit 1
    end

    def check_build_id!
      return if build_id
      puts "WARN: No builds found for #{project_name.color(:green)} project"
      exit
    end

    def show_console_log_url(build_id)
      log.info "Console Log Url:"
      build_id = build_id.split(":").last
      log.info "https://#{Jets.aws.region}.console.aws.amazon.com/codesuite/codebuild/projects/#{project_name}/build/#{project_name}%3A#{build_id}/log"
    end
  end
end
