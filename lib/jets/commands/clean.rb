module Jets::Commands
  class Clean < Jets::Commands::Base
    class_option :noop, type: :boolean, desc: "noop or dry-run mode"
    class_option :mute, type: :boolean, desc: "mute output"
    class_option :yes, type: :boolean, desc: "bypass are you sure prompt"

    desc "log", "Cleans CloudWatch log groups assocated with app"
    long_desc Help.text('clean:log')
    def log
      Log.new(options).clean
    end

    desc "build", "Cleans jets build"
    long_desc Help.text('clean:build')
    def build
      Build.new(options).clean
    end
  end
end
