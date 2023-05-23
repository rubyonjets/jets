module Jets::Command
  class BuildCommand < Base # :nodoc:
    include EnvironmentArgument

    option :templates, type: :boolean, desc: "Build CloudFormation templates only"

    desc "build", "Builds and packages project for AWS Lambda"
    long_desc Help.text(:build)
    def perform
      ENV['JETS_TEMPLATES'] = '1' if options[:templates]

      extract_environment_option_from_argument
      require_application_and_environment!

      puts "Building project for Lambda..."
      # run gets called from the CLI and does not have all the stack_options yet.
      # We compute it and change the options early here.
      @options.merge!(stack_type: stack_type, s3_bucket: Jets.s3_bucket)
      do_build
    end

  private
    # Note: build is picked up as a command so naming it do_build
    def do_build
      Jets::Builders::CodeBuilder.new.build unless ENV['JETS_TEMPLATES']
      Jets::Cfn::Builder.new(@options).build
    end

    def stack_type
      first_run? ? :minimal : :full
    end
  end
end
