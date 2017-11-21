module Jets::Application::Middleware
  def call(env)
    # only require when necessary because middleware is only used for development
    require "jets/webpacker/middleware_setup" # makes "use Webpacker::DevServerProxy" works
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
