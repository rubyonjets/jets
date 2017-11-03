class Jets::Application
  def self.call(env)
    triplet = assemble_app.call(env)
  end

  def self.assemble_app
    Rack::Builder.new do
      map("/") do
        use Jets::Server::TimingMiddleware
        run Jets::Server
      end
    end
  end
end
