class Jets::Server
  class TimingMiddleware
    FORMAT_STRING = "%0.6f" # :nodoc:
    HEADER_NAME = "X-Runtime" # :nodoc:

    def initialize(app)
      @app = app
    end

    def call(env)
      start_time = clock_time
      status, headers, body = @app.call(env)
      request_time = clock_time - start_time

      unless headers.has_key?(HEADER_NAME)
        headers[HEADER_NAME] = FORMAT_STRING % request_time
      end

      [status, headers, body]
    end

    private
    if defined?(Process::CLOCK_MONOTONIC)
      def clock_time
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end
    else
      def clock_time
        Time.now.to_f
      end
    end
  end
end
