require "webpacker"

class Jets::RakeTasks
  @@loaded = false
  def self.load!
    return if @@loaded # prevent loading twice if user has already loaded the
    # task in the project Rakefile.  Example:
    #
    #   require 'jets'
    #   Jets::RakeTasks.load!

    Jets::Commands::Db::Tasks.load!
    Webpacker::RakeTasks.load!
    @@loaded = true
  end
end
