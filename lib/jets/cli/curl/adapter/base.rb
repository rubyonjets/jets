module Jets::CLI::Curl::Adapter
  class Base
    extend Memoist
    def initialize(options)
      @options = options
    end
  end
end
