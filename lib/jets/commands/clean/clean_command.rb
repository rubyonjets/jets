module Jets::Command
  class CleanCommand < Base # :nodoc:
    desc "log", "Cleans CloudWatch log groups assocated with app"
    long_desc Help.text("clean/log")
    def log
      Jets::Commands::Clean::Log.new(options).clean
    end

    desc "build", "Cleans jets build"
    long_desc Help.text("clean/build")
    def build
      Jets::Commands::Clean::Build.new(options).clean
    end
  end
end
