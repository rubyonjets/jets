require "webpacker"

class Jets::RakeTasks
  def self.load!
    Jets::Db::Tasks.load!
    Webpacker::RakeTasks.load!
  end
end
