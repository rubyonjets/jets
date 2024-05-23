module Jets
  class Prewarm
    class << self
      include Jets::Util::Logging

      # Can use to prewarm post deploy
      # Jets::Prewarm.handle
      # Jets::Prewarm.handle(verbose: true, invocation_type: "RequestResponse")
      # Note: verbose is only useful when invocation_type is "RequestResponse"
      def handle(options = {})
        defaults = {
          function_name: "controller",
          event: '{"_prewarm": 1}'
        }
        options = defaults.merge(options.symbolize_keys)
        # Always calls Lambda, not local
        # Use invoke so messages don't get printed
        Jets::CLI::Call.new(options).invoke
      rescue Jets::CLI::Call::Error => e
        puts "ERROR: #{e.message}".color(:red)
        puts "The stack may not be full deployed yet.  Please check the stack and try again."
      end

      delegate :stats, to: Jets::Shim::Adapter::Prewarm
    end
  end
end
