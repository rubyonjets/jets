class Jets::Builders
  class LambdaLayer
    include Util

    # At this point we gems have all been moved to stage/code/vendor/gems, this includes
    # binary gems, a good state. This method moves them:
    #
    #   from stage/code/vendor/gems/ruby/2.5.0
    #   to stage/opt/ruby/gems/2.5.0
    #
    # So we can move gems into the Lambda Layer. Important folders later:
    #
    #   stage/code/opt/lib
    #   stage/code/opt/ruby
    #
    def build
      move_opt_to_stage
      move_vendor_to_opt
      symlink_vendor_gems
    end

    def move_opt_to_stage
      opt_original = "#{code_area}/opt"
      opt = "#{stage_area}/opt"
      FileUtils.mkdir_p(File.dirname(opt))
      FileUtils.mv(opt_original, opt)
    end

    def move_vendor_to_opt
      ruby_folder = Jets::Gems.ruby_folder
      gems_original = "#{code_area}/vendor/gems/ruby/#{ruby_folder}"
      gems = "#{stage_area}/opt/ruby/gems/#{ruby_folder}"

      FileUtils.mkdir_p(File.dirname(gems))
      FileUtils.mv(gems_original, gems)
      # Deleting in this way to make sure folders are empty before we delete them
      FileUtils.rmdir("#{code_area}/vendor/gems/ruby")
      FileUtils.rmdir("#{code_area}/vendor/gems")
      FileUtils.rmdir("#{code_area}/vendor") if Dir.empty?("#{code_area}/vendor")
    end

    # Simple logic: vendor/gems/ruby/2.5.0 -> /opt/ruby/gems/2.5.0
    def symlink_vendor_gems
      ruby_folder = Jets::Gems.ruby_folder
      dest = "#{code_area}/vendor/gems/ruby/#{ruby_folder}"
      FileUtils.mkdir_p(File.dirname(dest))
      # puts "ln -sf /opt/ruby/gems/#{ruby_folder} #{dest}" # uncomment to debug
      FileUtils.ln_sf("/opt/ruby/gems/#{ruby_folder}", dest)
    end
  end
end
