class Jets::CLI::Ci
  class Status < Base
    def run
      check_build_id!
      run_with_exception_handling do
        puts "Build id: #{build_id}"
        resp = codebuild.batch_get_builds(ids: [build_id])
        build = resp.builds.first
        puts "Build status: #{colored(build.build_status)}"
      end
    end

    private

    def colored(status)
      # one of SUCCEEDED FAILED FAULT TIMED_OUT IN_PROGRESS STOPPED
      case status
      when "SUCCEEDED"
        status.color(:green)
      when "FAILED", "FAULT", "TIMED_OUT"
        status.color(:red)
      when "IN_PROGRESS"
        status.color(:yellow)
      else
        status
      end
    end
  end
end
