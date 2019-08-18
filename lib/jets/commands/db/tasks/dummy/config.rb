require "recursive-open-struct"

module Jets::Commands::Db::Tasks::Dummy
  class Config < RecursiveOpenStruct
    def load_database_yaml # :nodoc:
      require "rails/application/dummy_erb_compiler"

      path = "#{Jets.root}/config/database.yml"
      yaml = Pathname.new(path)
      erb = DummyERB.new(yaml.read)
      YAML.load(erb.result) || {}
    end
  end
end