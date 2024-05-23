module Jets::Shim::Adapter
  class Prewarm < Base
    @@prewarm_count = 0
    @@prewarm_at = nil

    def handle
      @@prewarm_count += 1
      @@prewarm_at = Time.now.utc
      result = self.class.stats
      log.info "Prewarm request: #{JSON.dump(result)}" if ENV["JETS_PREWARM_LOG"]
      result
    end

    def handle?
      event["_prewarm"]
    end

    def self.stats
      {
        boot_at: Jets::Core::Booter.boot_at,
        gid: Jets::Core::Booter.gid,
        prewarm_at: @@prewarm_at,
        prewarm_count: @@prewarm_count
      }
    end
  end
end
