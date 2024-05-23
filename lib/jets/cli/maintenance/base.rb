class Jets::CLI::Maintenance
  class Base < Jets::CLI::Base
    include Jets::CLI::Lambda::Checks
    include Jets::Util::Truthy

    def initialize(options = {})
      super
      check_deployed!
    end

    def status
      on? ? "on" : "off"
    end
  end
end
