module Jets
  class RackServer
    def self.start(options={})
      new(options).start
    end

    def initialize(options={})
      @options = options
    end

    def start
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
        args = ''
        args << " --host #{@options[:host]}" if @options[:host] # only forward the host option
                                                                # port is always 9292 for simplicity
        command = "cd #{rack_project} && bin/rackup#{args}" # leads to the same wrapper rack scripts
        puts "=> #{command}".colorize(:green)
        system(command)
      end
    end

    # blocks until rack server is up
    def wait_for_socket
      return unless Jets.rack?

      retries = 0
      max_retries = 30 # 15 seconds at a delay of 0.5s
      delay = 0.5
      if ENV['C9_USER'] # overrides for local testing
        max_retries = 3
        delay = 3
      end
      begin
        server = TCPSocket.new('localhost', 9292)
        server.close
      rescue Errno::ECONNREFUSED
        puts "Unable to connect to localhost:9292. Delay for #{delay} and will try to connect again."  if ENV['JETS_DEBUG']
        sleep(delay)
        retries += 1
        if retries < max_retries
          retry
        else
          puts "Giving up on trying to connect to localhost:9292"
          return false
        end
      end
      puts "Connected to localhost:9292 successfully"
      true
    end

    def rack_project
      "#{Jets.root}rack"
    end
  end
end