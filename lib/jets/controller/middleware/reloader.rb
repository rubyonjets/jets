module Jets::Controller::Middleware
  class Reloader
    def initialize(app)
      @app = app
    end

    @@reload_lock = Mutex.new
    def call(env)
      @@reload_lock.synchronize do
        Jets::Autoloaders.main.reload
        @app.call(env)
      end
    end
  end
end
