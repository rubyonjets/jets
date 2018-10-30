class Jets::Builders
  class RackPackager < RubyPackager
    def finish
      return unless gemfile_exist?

      symlink_rack_bundled
      copy_rackup_wrappers
    end

    def symlink_rack_bundled
      # IE: @full_app_root: /tmp/jets/demo/stage/code/rack
      rack_bundled = "#{@full_app_root}/bundled"
      FileUtils.rm_f(rack_bundled) # looks like FileUtils.ln_sf doesnt remove existing symlinks
      FileUtils.ln_sf("/var/task/bundled", rack_bundled)
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
  end
end