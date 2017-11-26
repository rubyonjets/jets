module Jets::Application::Middleware
  def call(env)
    # Only require when necessary because middleware is only used for development
    # Requring here instead of top of file because Jets::Application::Middleware
    # gets autoloaded when Jets::Application gets autoloaded.
    # Trying to keep the config.ru interface clean:
    #
    #   require "jets"
    #   Jets.boot
    #   run Jets.application
    require "jets/server/webpacker_setup" # makes "use Webpacker::DevServerProxy" works
    triplet = assemble_app.call(env)
  end

  def assemble_app
    Rack::Builder.new do
      map("/") do
        use Jets::Server::TimingMiddleware
        use Webpacker::DevServerProxy
        run Jets::Server
      end
    end
  end
end
