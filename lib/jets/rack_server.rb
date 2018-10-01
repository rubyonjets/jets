require 'fileutils'

module Jets
  class RackServer
    def self.run
      new.run
    end

    def run
      puts "Running RackServer..."

      if ENV['JETS_RACK_FOREGROUND']
        serve
        return
      end

      # Reaching here means we'll run the server in the background
      pid = Process.fork
      if pid.nil?
        # we're in the child process
        serve
      else
        # we're in the parent process
        Process.detach(pid)
      end
    end

    # Runs in the child process
    def serve
      Bundler.with_clean_env do
        rack_project = "#{Jets.root}rack"
        command = "cd #{rack_project} && bin/rackup"
        puts "=> #{command}".colorize(:green)
        system(command)
      end
    end
  end
end