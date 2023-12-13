class Jets::CLI
  class Release < Jets::Thor::Base
    desc "history", "Release history"
    paging_options(order: "desc", limit: 10)
    def history
      History.new(options).run
    end
    map list: :history

    desc "info", "Release detailed information"
    format_option(default: "info")
    def info(version = nil)
      Info.new(options.merge(version: version)).run
    end
    map show: :info

    desc "rollback VERSION", "Rollback to a previous release", hide: true
    option :yes, aliases: :y, type: :boolean, desc: "Skip are you sure prompt"
    def rollback(version)
      Rollback.new(options.merge(version: version)).run
    end
  end
end
