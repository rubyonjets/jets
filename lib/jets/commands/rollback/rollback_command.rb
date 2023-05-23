require "jets/commands/releases/releases_command"

module Jets::Command
  class RollbackCommand < Base # :nodoc:
    desc "rollback", "Rollback to a previous release"
    long_desc Help.text(:rollback)
    def perform(version=nil)
      Rollback.new(options.merge(version: version)).run
    end
  end

  class Rollback
    include Jets::Command::ApiHelpers
    attr_reader :version
    def initialize(options={})
      @options = options
      @version = options[:version]
      # Handle more gracefully than the way Jets does it currently
      if @version.nil?
        puts <<~EOL
          ERROR: version required
          Usage: jets rollback VERSION
        EOL
        exit 1
      end
    end

    def run
      no_token_exit!
      Jets.boot
      payload = Release.new(@options).get(version)
      check_for_error_message!(payload)

      puts "Rolling back to version #{version}"
      # Download previous cfn templates
      Jets::Cfn::Download.new.download_templates(version)
      # Run cloudformation update
      Jets::Cfn::Ship.new(@options.merge(rollback_version: version)).run # also creates the Jets Api deployment record
    end
  end
end
