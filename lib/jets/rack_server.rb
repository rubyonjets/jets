require 'pidfile'
require 'fileutils'

module Jets
  class RackServer
    def self.run
      new.run
    end

    def run
      puts "Running RackServer..."

      # serve
      # return

      # Reaching here means we'll run the server in the background
      pid = Process.fork
      if pid.nil?
        # we're in the child process
        serve
      else
        # we're in the parent process
        Process.detach(pid)
      end

      # loop do
      #   puts "looping"
      #   sleep 3
      # end
    end

    # Runs in the child process
    def serve
      # pidfile
      Bundler.with_clean_env do
        rack_project = "#{Jets.root}rack"
        command = "cd #{rack_project} && bin/rackup"
        puts "=> #{command}".colorize(:green)
        system(command)
      end
    end

    # def pidfile_path
    #   "/tmp/jets-rackup.pid"
    # end

    # def pidfile
    #   _, dir, file = pidfile_path.split('/')
    #   @pidfile ||= PidFile.new(:piddir => "/#{dir}", :pidfile => file)
    # end


    def stop
      unless PidFile.running?(pidfile_path)
        puts "Unable to stop rackup because it is not running."
      else
        pid = open(pidfile_path, 'r').read.to_i
        Process.kill("HUP", pid)
        puts "The rackup process has been stopped"
      end
    end
  end
end