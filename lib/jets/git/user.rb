module Jets::Git
  class User
    extend Memoist
    include GitCli

    def first_name
      name.split(" ").first if name # name can be nil
    end

    def name
      saved[:git_user] || git_config["user.name"]
    end

    def saved
      return {} unless File.exist?(".jets/gitinfo.yml")
      data = YAML.load_file(".jets/gitinfo.yml")
      ActiveSupport::HashWithIndifferentAccess.new(data)
    end

    def git_config
      return {} if ENV["JETS_GIT_DISABLED"]

      return {} unless git?
      list = git("config --list")
      lines = list.split("\n")
      # Other values in the git config are not needed.
      # And can cause .to_h to bomb and throw an error.
      lines.select! { |l| l =~ /^user\./ }
      lines.map { |l| l.split("=") }.to_h
    end
    memoize :git_config
  end
end
