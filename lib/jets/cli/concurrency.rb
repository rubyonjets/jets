class Jets::CLI
  class Concurrency < Jets::Thor::Base
    desc "info", "Concurrency info"
    format_option(default: "table")
    def info
      Info.new(options).run
    end

    desc "get", "Get concurrency for function"
    function_name_option
    def get
      Get.new(options).run
    end

    desc "set", "Set concurrency for function"
    function_name_option
    option :reserved, type: :numeric, desc: "Reserved concurrency"
    option :provisioned, type: :numeric, desc: "Provisioned concurrency"
    yes_option
    def set
      Set.new(options).run
    end

    desc "unset", "Unset concurrency for function"
    function_name_option
    option :reserved, type: :boolean, desc: "Reserved concurrency"
    option :provisioned, type: :boolean, desc: "Provisioned concurrency"
    yes_option
    def unset
      Unset.new(options).run
    end
  end
end
