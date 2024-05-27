class Jets::CLI
  class Git < Jets::Thor::Base
    desc "push", "Runs git push and jets ci:logs"
    def push(*args)
      Push.new(options.merge(args: args)).run
    end
  end
end
