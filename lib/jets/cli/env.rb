class Jets::CLI
  class Env < Jets::Thor::Base
    class_option :function, aliases: :n, default: "controller", desc: "Lambda Function name"

    desc "list", "List and show env vars"
    format_option(default: "dotenv")
    option :reveal, type: :boolean, default: false, desc: "Reveal values also"
    def list
      List.new(options).run
    end

    desc "get NAME", "Get env vars for function"
    def get(name)
      Get.new(options.merge(key: name)).run
    end

    desc "set VALUES", "Set env vars for function"
    yes_option
    def set(*values)
      Set.new(options.merge(values: values)).run
    end

    desc "unset NAMES", "Unset env vars for function"
    yes_option
    def unset(*names)
      Unset.new(options.merge(names: names)).run
    end
  end
end
