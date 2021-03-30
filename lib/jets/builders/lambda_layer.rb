module Jets::Builders
  class LambdaLayer
    include Util

    # At this point gems are in the stage/code and stage/rack folders still.
    # We consolidate all gems to stage/opt.
    # Then replace the binary gems.
    def build
      consolidate_gems_to_opt
      replace_compiled_gems unless Jets.config.gems.disable
    end

    # Also restructure the folder from:
    #   vendor/gems/ruby/2.5.0
    # To:
    #   ruby/gems/2.5.0
    #
    # For Lambda Layer structure
    def consolidate_gems_to_opt
      src = "#{stage_area}/code/vendor/gems/ruby/#{Jets.ruby_folder}"
      dest = "#{stage_area}/opt/ruby/gems/#{Jets.ruby_folder}"
      rsync_and_link(src, dest)

      return unless Jets.rack?

      src = "#{stage_area}/rack/vendor/gems/ruby/#{Jets.ruby_folder}"
      rsync_and_link(src, dest)
    end

    def rsync_and_link(src, dest)
      FileUtils.mkdir_p(dest)
      # Trailing slashes are required
      sh "rsync -a --links #{src}/ #{dest}/"

      FileUtils.rm_rf(src) # blow away original 2.5.0 folder

      # Create symlink that will point to the gems in the Lambda Layer:
      #   stage/opt/ruby/gems/2.5.0 -> /opt/ruby/gems/2.5.0
      FileUtils.ln_sf("/opt/ruby/gems/#{Jets::Gems.ruby_folder}", src)
    end

    # replace_compiled_gems:
    #   remove binary gems in vendor/gems/ruby/2.5.0
    #   extract binary gems in opt/ruby/gems/2.5.0
    #   move binary gems from opt/ruby/gems/2.5.0 to vendor/gems/ruby/2.5.0
    #
    # After this point, gems have been replace in stage/code/vendor/gems with their
    # binary extensions: a good state. This method moves these gems to the Lambda
    # Layers structure and creates a symlinks to it.  First:
    #
    #   from stage/code/vendor/gems/ruby/2.5.0
    #   to stage/opt/ruby/gems/2.5.0
    #
    # Then:
    #
    #   stage/code/vendor/gems/ruby/2.5.0 -> /opt/ruby/gems/2.5.0
    #
    def replace_compiled_gems
      project_root = "#{stage_area}/opt"
      headline "Replacing compiled gems with AWS Lambda Linux compiled versions: #{project_root}"
      options = {
        build_root: cache_area, # used in jets-gems
        project_root: project_root, # used in gem_replacer and jets-gems
      }
      GemReplacer.new(options).run
    end
  end
end
