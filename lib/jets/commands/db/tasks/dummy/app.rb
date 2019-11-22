require "recursive-open-struct"

module Jets::Commands::Db::Tasks::Dummy
  class App
    def config
      Config.new(
        active_record: {
          belongs_to_required_by_default: true
        },
        paths: {
          db: ["db"],
          "db/migrate": ["db/migrate"]
        }
      )
    end

    def paths
      RecursiveOpenStruct.new(
        paths: {
          "db/migrate": ["db/migrate"]
        }
      )
    end
  end
end
