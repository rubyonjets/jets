class Jets::CLI
  class Ping < Base
    rescue_api_error

    def run
      Jets::Api::Ping.create
      puts "Auth check successful"
    end
  end
end
