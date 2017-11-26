require "webpacker"

class Jets::RakeTasks
  def self.load!
    Jets::Commands::Db::Tasks.load!
    Webpacker::RakeTasks.load!
  end
end
