module Jets
  class RackServer
    def self.run
      new.run
    end

    def run
      puts "Running RackServer..."

      serve
      return

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

    def serve
      Bundler.with_clean_env do
        rack_project = "#{Jets.root}rack"
        system("cd #{rack_project} && bin/rackup")
      end
    end
  end
end