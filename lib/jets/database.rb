require "active_record"

class Jets::Database < Jets::Command
  def self.connect
    ActiveRecord::Base.establish_connection(config[Jets.env])
  end

  def self.config
    text = Jets::Erb.result("#{Jets.root}config/database.yml")
    YAML.load(text)
  end
end
