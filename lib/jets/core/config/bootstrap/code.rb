class Jets::Core::Config::Bootstrap
  module Code
    attr_accessor :code

    def initialize(*)
      super

      @code = ActiveSupport::OrderedOptions.new
      @code.copy = ActiveSupport::OrderedOptions.new
      @code.copy.always_keep = ["config/jets/env"]
      @code.copy.always_remove = ["tmp"]
      @code.copy.strategy = "auto"
      @code.copy.warn_large = true
    end
  end
end
