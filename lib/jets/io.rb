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
        pidfile = "/tmp/jets-rackup.pid"
        if File.exist?(pidfile)
          pid = IO.read(pidfile).strip
          # send signal to flush rack log, which is another process
          Process.kill("IO", pid)
        end
      end
    end
  end
end
