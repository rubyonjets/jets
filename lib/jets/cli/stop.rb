class Jets::CLI
  class Stop < Jets::CLI::Ci::Base
    def run
      are_you_sure?
      check_build_id!
      run_with_exception_handling do
        stopped = stop_build
        if stopped
          log.info <<~EOL
            Deploy has been stopped: #{build_id}
            Note: If the deploy has already started the CloudFormation update,
            it will continue. Please check the logs.

          EOL
          show_console_log_url(build_id)
        end
      end
    end

    def stack_name
      "#{Jets.project.namespace}-remote"
    end
    alias_method :project_name, :stack_name

    def are_you_sure?
      unless @options[:yes]
        sure? "Will attempt to stop the deploy for project #{project_name.color(:green)} build_id #{build_id.color(:green)}"
      end
    end
  end
end
