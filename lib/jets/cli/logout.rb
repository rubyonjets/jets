class Jets::CLI
  class Logout < Base
    def run
      Jets::Api::Config.instance.clear_token
    end
  end
end
