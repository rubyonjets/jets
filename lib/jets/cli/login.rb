class Jets::CLI
  class Login < Base
    def run
      Jets::Api::Config.instance.update_api_key(@options[:token])
    end
  end
end
