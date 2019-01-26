class Jets::Commands::Import
  class Cheatsheet
    def self.create(rack_repo_url)
      new(rack_repo_url).create
    end

    def initialize(rack_repo_url)
      @rack_repo_url = rack_repo_url
    end

    def create
      path = File.expand_path("./templates/", File.dirname(__FILE__)) + "/submodules-cheatsheet.md"
      basename = File.basename(path)
      dest = "#{Jets.root}/#{basename}"
      cheatsheet = Jets::Erb.result(path, cheatsheet_vars)
      FileUtils.mkdir_p(File.dirname(dest))
      IO.write(dest, cheatsheet)
      puts "Created #{basename} to help with using submodules."
    end

    def cheatsheet_vars
      import_command = ARGV[0]
      {
        import_command: import_command,
        rack_repo_url: @rack_repo_url,
        jets_project_repo_url: jets_project_repo_url,
      }
    end

    def jets_project_repo_url
      # Thanks: https://stackoverflow.com/questions/4089430/how-can-i-determine-the-url-that-a-local-git-repository-was-originally-cloned-fr/4089452
      `git config --get remote.origin.url`.strip rescue 'https://github.com/user/repo'
    end
  end
end