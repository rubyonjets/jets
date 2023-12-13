class Jets::CLI
  class Waf < Jets::Thor::Base
    class << self
      # interface method
      def waf_name
        [Jets.env, Jets.extra].compact.join("-")
      end
    end

    Init.cli_options.each { |args| option(*args) }
    register(Init, "init", "init", "WAF init creates config/jets/waf.rb")

    desc "build", "WAF build"
    yes_option
    def build
      Build.new(options).run
    end

    desc "deploy", "WAF deploy"
    yes_option
    def deploy
      Deploy.new(options).run
    end

    desc "delete", "WAF delete"
    yes_option
    def delete
      Delete.new(options).run
    end

    desc "info", "WAF info"
    format_option(default: "info")
    option :name, aliases: :n, default: waf_name, desc: "Web ACL name"
    def info
      Info.new(options).run
    end
  end
end
