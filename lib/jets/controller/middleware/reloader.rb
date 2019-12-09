module Jets::Controller::Middleware
  class Reloader
    def initialize(app)
      @app = app
    end

    @@reload_lock = Mutex.new
    def call(env)
      @@reload_lock.synchronize do
        Zeitwerk::Loader.eager_load_all
        @app.call(env)
      end
    end
  end
end
