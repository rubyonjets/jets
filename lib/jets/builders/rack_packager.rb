class Jets::Builders
  class RackPackager < RubyPackager
    def finish
      return unless gemfile_exist?

      symlink_gems
      rack_symlink
      copy_rackup_wrappers
    end

    def symlink_gems
      ruby_folder = Jets::Gems.ruby_folder
      # IE: @full_app_root: /tmp/jets/demo/stage/code/rack
      dest = "#{@full_app_root}/vendor/bundle/ruby/#{ruby_folder}"
      FileUtils.mkdir_p(File.dirname(dest))
      FileUtils.ln_sf("/opt/ruby/gems/#{ruby_folder}", dest)
    end

    def copy_rackup_wrappers
      # IE: @full_app_root: /tmp/jets/demo/stage/code/rack
      rack_bin = "#{@full_app_root}/bin"
      %w[rackup rackup.rb].each do |file|
        src = File.expand_path("./rackup_wrappers/#{file}", File.dirname(__FILE__))
        dest = "#{rack_bin}/#{file}"
        FileUtils.mkdir_p(rack_bin) unless File.exist?(rack_bin)
        FileUtils.cp(src, dest)
        FileUtils.chmod 0755, dest
      end
    end

    # Moves folder to a stage folder and create a symlink its place
    # that links from /var/task to /tmp. Example:
    #
    #   code_area/rack => /tmp/rack
    #
    def rack_symlink
      src = "#{@full_app_root}/rack"
      return unless File.exist?(src)

      dest = "#{stage_area}/rack"
      dir = File.dirname(dest)
      FileUtils.mkdir_p(dir) unless File.exist?(dir)
      FileUtils.mv(src, dest)

      # Create symlink
      FileUtils.ln_sf("/tmp/rack", "/#{@full_app_root}/rack")
    end
  end
end