class Jets::CLI::Ci
  class Stop < Base
    def run
      are_you_sure?
      check_build_id!
      run_with_exception_handling do
        stopped = stop_build
        log.info "Build has been stopped: #{build_id}" if stopped
        show_console_log_url(build_id)
      end
    end

    private

    def are_you_sure?
      message = "Will stop build for project #{project_name.color(:green)} build_id #{build_id.color(:green)}"
      if @options[:yes]
        logger.info message
      else
        sure?(message)
      end
    end
  end
end
