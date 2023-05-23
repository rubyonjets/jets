module Jets::Router
  class EngineMount
    def self.find_by(request_path: nil, engine: nil)
      new.find_by(request_path: request_path, engine: engine)
    end

    def find_by(request_path: nil, engine: nil)
      mount = if request_path
                find_by_request_path(request_path)
              elsif engine
                find_by_engine(engine)
              end

      return unless mount

      OpenStruct.new(at: mount[0], engine: mount[1])
    end

    def find_by_request_path(request_path)
      mounted_engines.find do |at, engine|
        request_path.starts_with?(at)
      end
    end

    def find_by_engine(engine)
      mounted = mounted_engines.find do |at, mounted_engine|
        mounted_engine == engine
      end
    end

    # Example mounted_engines: {"/blog"=>Blorgh::Engine}
    def mounted_engines
      Jets::Router::Dsl::Mount.mounted_engines
    end
  end
end
