class Jets::CLI::Ci
  class Logs < Base
    def run
      check_build_id!
      run_with_exception_handling do
        puts "Logs for #{build_id}"
        show_console_log_url(build_id)
        Tailer.new(@options, build_id).run
      end
    end
  end
end
