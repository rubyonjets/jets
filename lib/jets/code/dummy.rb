class Jets::Code
  class Dummy < Stager
    def stage_code
      # copies jets config
      return unless File.exist?("#{Jets.root}/config/jets")
      FileUtils.rm_rf("#{build_root}/stage/code/config/jets")
      FileUtils.mkdir_p("#{build_root}/stage/code/config")
      FileUtils.cp_r("#{Jets.root}/config/jets", "#{build_root}/stage/code/config/jets")
    end
  end
end
