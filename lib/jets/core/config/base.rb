require "singleton"

module Jets::Core::Config
  class Base
    extend Memoist
    include Jets::Util::Camelize
    include Singleton

    def configure(&block)
      instance_eval(&block) if block
    end

    def config
      self
    end
  end
end
