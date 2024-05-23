class Jets::CLI
  class Deploy < Base
    def run
      dev_mode_check!
      sure?("Will deploy #{Jets.project.namespace.color(:green)}")
      Tip.show(:faster_deploy)

      Jets::Cfn::Bootstrap.new(@options).run
      Jets::Remote::Runner.new(@options.merge(command: "deploy")).run
    end

    def dev_mode_check!
      if File.exist?("#{Jets.root}/dev.mode") && !ENV["JETS_SKIP_DEV_MODE_CHECK"]
        abort "The dev.mode file exists. Please removed it and run bundle update before you deploy.".color(:red)
      end
    end
  end
end
