class Jets::CLI
  class Dotenv < Jets::Thor::Base
    desc "list", "Parse and list dotenv vars"
    format_option(default: "dotenv")
    option :reveal, type: :boolean, default: false, desc: "Reveal values also"
    def list
      List.new(options).run
    end

    desc "get NAME", "Get env var from local files and SSM"
    def get(name)
      Get.new(options.merge(name: name)).run
    end

    desc "set VALUES", "Set SSM env vars for function"
    yes_option
    option :secure, type: :boolean, default: true, desc: "Whether or not to use SSM parameter type SecureString or String"
    def set(*values)
      Set.new(options.merge(values: values)).run
    end

    desc "unset NAMES", "Unset SSM env vars for function"
    yes_option
    def unset(*names)
      Unset.new(options.merge(names: names)).run
    end
  end
end
