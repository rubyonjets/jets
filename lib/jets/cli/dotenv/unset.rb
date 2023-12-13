class Jets::CLI::Dotenv
  class Unset < Set
    def perform
      ssm_manager.delete(names)
    end

    def names
      @options[:names]
    end
  end
end
