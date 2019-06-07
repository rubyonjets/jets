module Jets::Controller::Middleware
  class Reloader
    def initialize(app)
      @app = app
      @loader = Jets::Autoloaders.main
      $mutex ||= Mutex.new
    end

    def call(env)
      $mutex.synchronize do
        @loader.reload
        @app.call(env)
      end
    end
  end
end
