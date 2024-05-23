class Jets::CLI::Waf
  class Init < Jets::CLI::Group::Base
    include Jets::Util::Sure

    def self.cli_options
      [
        [:force, aliases: :f, type: :boolean, desc: "Bypass overwrite are you sure prompt for existing files"],
        [:yes, aliases: :y, type: :boolean, desc: "Skip are you sure prompt"]
      ]
    end
    cli_options.each { |args| class_option(*args) }

    source_root "#{__dir__}/templates"

    private

    def sure_message
      <<~EOL
        This will create a config/jets/waf.rb file with initial waf settings.

        The waf is designed to be a shared resource used by multiple projects.
        Having a separate project that manages the waf stack may make sense.

        Please make sure you have backed up and committed your changes first.
      EOL
    end

    public

    def are_you_sure?
      return if options[:yes]
      sure?(sure_message)
    end

    # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codebuild-project-source.html#cfn-codebuild-project-source-type
    def config_jets_ci
      template "waf.rb.tt", "config/jets/waf.rb"
    end
  end
end
