# Wrapper class works with jets/core_ext/kernel.rb
module Jets
  class IO
    class << self
      def buffer
        Kernel.io_buffer
      end

      def flush
        Kernel.io_flush
      end
    end
  end
end
