class Jets::CLI
  class Package < Jets::Thor::Base
    desc "dockerfile", "Build dockerfile"
    def dockerfile
      Dockerfile.new(options).run
    end
  end
end
