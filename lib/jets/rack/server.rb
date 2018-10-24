require 'fileutils'

module Jets::Rack
  class Server
    def self.start
      new.start
    end

    def start
      puts "Jets::Rack#start"
      return unless File.exist?("#{rack_project}/config.ru")
      puts "Starting additional rack server for the project under the rack subfolder..." if ENV['JETS_DEBUG']

      if ENV['FOREGROUND']
        serve
        return
      end

      # Reaching here means we'll run the server in the background.
      # Handle daemonzing ourselves because it keeps the stdout of the 2nd
      # rack server. The rackup --daemonize option ends up hiding the output.
      pid = Process.fork
      if pid.nil?
        # we're in the child process
        serve
      else
        # we're in the parent process
        Process.detach(pid) # dettached but still in the "foreground" since bin/rackup runs in the foreground
      end
    end

    # Runs in the child process
    def serve
      # Note, looks like stopping jets server with Ctrl-C sends the TERM signal
      # down to the sub bin/rackup command cleans up the child process fine.
      Bundler.with_clean_env do
        command = "cd #{rack_project} && bin/rackup" # leads to the same wrapper rack scripts
        puts "=> #{command}".colorize(:green)
        system(command)
      end
    end

    def rack_project
      "#{Jets.root}rack"
    end
  end
end