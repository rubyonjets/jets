module Jets::Command
  class ConfigureCommand < Base # :nodoc:
    desc "configure [TOKEN]", "configure token and updates ~/.jets/config.yml"
    long_desc Help.text(:configure)
    def perform(token=nil)
      Jets::Api::Config.instance.update_token(token)
    end
  end
end
