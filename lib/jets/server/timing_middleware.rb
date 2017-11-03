class Jets::Server
  class TimingMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      before = Time.now.to_i
      status, headers, body = @app.call(env)
      after = Time.now.to_i
      log_message = "App took #{after - before} seconds.\n"
      headers["Timing"] = "App took #{after - before} seconds.\n"
      [status, headers, body]
    end
  end
end
