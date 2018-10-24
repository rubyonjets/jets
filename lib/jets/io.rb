# Wrapper class works with jets/core_ext/kernel.rb
module Jets
  class IO
    class << self
      def buffer
        Kernel.io_buffer
      end

      def flush
        Kernel.io_flush
        flush_rack
      end

      def flush_rack
        # Tip: to debug and see errors if debugging the node shim with: node hi.js
        #
        #   cat /tmp/shim-subprocess.log
        #
        pidfile = "/tmp/jets-rackup.pid"
        if File.exist?(pidfile)
          pid = File.read(pidfile).to_i
          # send signal to flush rack log, which is another process
          begin
            Process.kill("IO", pid)
            sleep 5 # DEBUGGING
          rescue Errno::ESRCH
           # Could have a stale pidfile from an old jets app that had a rack subfolder.
           # Then we switch over to a jets app that does not have a rack subfolder,
           # the old /tmp/jets-rackup.pid might still be around.
         end
        end
      end
    end
  end
end
