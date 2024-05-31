module Jets::Thor
  class ProjectCheck
    class NotProjectError < StandardError; end

    def initialize(args)
      @args = args
    end

    def check!
      return if project? || no_project_command?
      raise NotProjectError, "Not a Jets project. Please run this command from a Jets project folder."
    end

    def project?
      File.exist?("config/jets")
    end

    # Tricky: Thor load the command and then the subcommand.
    # IE: jets generate:event
    #     @args = ["generate", "event"] # first pass
    #     @args = ["event"]             # second pass
    # We only check first pass to see if it is a no_project_command.
    # And cache it so the second pass never occurs.
    @@no_project_command = nil
    def no_project_command?
      return @@no_project_command unless @@no_project_command.nil?
      @@no_project_command = (no_project_commands & @args).any? || @args.empty?
    end

    def no_project_commands
      # generate for generate:event
      # Allow generate in case `jets init` has not been called yet and user
      # can generate event classes before `jets init` is called.
      #
      # The delete command is a special case. It is allowed to run without a project
      # in an empty folder. This is because the delete command is used to clean up
      # Jets API deployment record.
      commands = %w[
        delete
        generate
        init
        login
        logout
        projects
        version
      ]
      commands + Jets::Thor::Base.help_flags + Jets::Thor::Base.version_flags
    end
  end
end
