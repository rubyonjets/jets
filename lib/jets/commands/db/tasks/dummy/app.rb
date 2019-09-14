require "recursive-open-struct"

module Jets::Commands::Db::Tasks::Dummy
  class App
    def config
      Config.new(
        paths: {
          db: ["db"],
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
