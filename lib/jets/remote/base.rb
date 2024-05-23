module Jets::Remote
  class Base
    extend Memoist
    include Jets::AwsServices
    include Jets::Util::Logging

    def initialize(options)
      @options = options
    end
  end
end
