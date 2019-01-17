require "bundler" # for clean_old_submodules only

class Jets::Builders
  class RubyPackager
    include Util

    attr_reader :full_app_root
    def initialize(relative_app_root)
      @full_app_root = "#{build_area}/#{relative_app_root}"
    end

    def install
      return unless gemfile_exist?

      reconfigure_ruby_version
      clean_old_submodules
      bundle_install
      setup_bundle_config
      copy_cache_gems
    end

    #   build gems in vendor/gems/ruby/2.5.0 (done in install phase)
    def finish
      return unless gemfile_exist?
      tidy
    end

    def gemfile_exist?
      gemfile_path = "#{@full_app_root}/Gemfile"
      File.exist?(gemfile_path)
    end

    # Installs gems on the current target system: both compiled and non-compiled.
    # If user is on a macosx machine, macosx gems will be installed.
    # If user is on a linux machine, linux gems will be installed.
    #
    # Copies Gemfile* to /tmp/jets/demo/cache folder and installs
    # gems with bundle install from there.
    #
    # We take the time to copy Gemfile and bundle into a separate directory
    # because it gets left around to act as a 'cache'.  So, when the builds the
    # project gets built again not all the gems from get installed from the
    # beginning.
    def bundle_install
      full_project_path = @full_app_root
      headline "Bundling: running bundle install in cache area: #{cache_area}."

      copy_gemfiles(full_project_path)

      # Uncomment out to always remove the cache/vendor/gems to debug
      # FileUtils.rm_rf("#{cache_area}/vendor/gems")

      require "bundler" # dynamically require bundler so user can use any bundler
      Bundler.with_clean_env do
        sh(
          "cd #{cache_area} && " \
          "env BUNDLE_IGNORE_CONFIG=1 bundle install --path #{cache_area}/vendor/gems --without development test"
        )
      end

      # Copy the Gemfile.lock back to the project in case it was updated.
      # For example we add the jets-rails to the Gemfile.
      copy_back_gemfile_lock

      puts 'Bundle install success.'
    end

    def copy_back_gemfile_lock
      src = "#{cache_area}/Gemfile.lock"
      dest = "#{@full_app_root}/Gemfile.lock"
      FileUtils.cp(src, dest)
    end

    # Clean up extra unneeded files to reduce package size
    # Because we're removing files (something dangerous) use full paths.
    def tidy
      puts "Tidying project: removing ignored files to reduce package size."
      tidy_project(@full_app_root)
      # The rack sub project has it's own gitignore.
      tidy_project(@full_app_root+"/rack")
    end

    def tidy_project(path)
      Tidy.new(path).cleanup!
    end

    # This is in case the user has a 2.5.x variant.
    # Force usage of ruby version that jets supports
    # The lambda server only has ruby 2.5.0 installed.
    def reconfigure_ruby_version
      ruby_version = "#{@full_app_root}/.ruby-version"
      IO.write(ruby_version, Jets::RUBY_VERSION)
    end

    # When using submodules, bundler leaves old submodules behind. Over time this inflates
    # the size of the the cache gems.  So we'll clean it up.
    def clean_old_submodules
      # https://stackoverflow.com/questions/38800129/parsing-a-gemfile-lock-with-bundler
      lockfile = "#{cache_area}/Gemfile.lock"
      return unless File.exist?(lockfile)

      return if Bundler.bundler_major_version <= 1 # LockfileParser only works for Bundler version 2+

      parser = Bundler::LockfileParser.new(Bundler.read_file(lockfile))
      specs = parser.specs

      # specs = Bundler.load.specs
      # IE: spec.source.to_s: "https://github.com/tongueroo/webpacker.git (at jets@a8c4661)"
      submoduled_specs = specs.select do |spec|
        spec.source.to_s =~ /@\w+\)/
      end

      # find git shas to keep
      # IE: ["a8c4661", "abc4661"]
      git_shas = submoduled_specs.map do |spec|
        md = spec.source.to_s.match(/@(\w+)\)/)
        md[1] # git_sha
      end

      # IE: /tmp/jets/demo/cache/vendor/gems/ruby/2.5.0/bundler/gems/webpacker-a8c46614c675
      Dir.glob("#{cache_area}/vendor/gems/ruby/2.5.0/bundler/gems/*").each do |path|
        sha = path.split('-').last[0..6] # only first 7 chars of the git sha
        unless git_shas.include?(sha)
          # puts "Removing old submoduled gem: #{path}" # uncomment to see and debug
          FileUtils.rm_rf(path) # REMOVE old submodule directory
        end
      end
    end

    def copy_gemfiles(full_project_path)
      FileUtils.mkdir_p(cache_area)
      FileUtils.cp("#{full_project_path}/Gemfile", "#{cache_area}/Gemfile")

      gemfile_lock = "#{full_project_path}/Gemfile.lock"
      dest = "#{cache_area}/Gemfile.lock"
      return unless File.exist?(gemfile_lock)

      FileUtils.cp(gemfile_lock, dest)
      adjust_gemfile_lock(dest)
    end

    # Remove the BUNDLED WITH line since we don't control the bundler gem version on AWS Lambda
    # And this can cause issues with require 'bundler/setup'
    def adjust_gemfile_lock(path)
      lines = IO.readlines(path)
      n = lines.index { |l| l.include?("BUNDLED WITH") }
      return unless n

      new_lines = lines[0..n-1]
      content = new_lines.join('')
      IO.write(path, content)
    end

    def setup_bundle_config
      ensure_build_cache_bundle_config_exists!

      # Override project's .bundle/config and ensure that .bundle/config matches
      # at these 2 spots:
      #   app_root/.bundle/config
      #   vendor/gems/.bundle/config
      cache_bundle_config = "#{cache_area}/.bundle/config"
      app_bundle_config = "#{@full_app_root}/.bundle/config"
      FileUtils.mkdir_p(File.dirname(app_bundle_config))
      FileUtils.cp(cache_bundle_config, app_bundle_config)
    end

    # On circleci the "#{Jets.build_root}/.bundle/config" doesnt exist
    # this only happens with ssh debugging, not when the ci.sh script gets ran.
    # But on macosx it exists.
    # Dont know why this is the case.
    def ensure_build_cache_bundle_config_exists!
      text =<<-EOL
---
BUNDLE_FROZEN: "true"
BUNDLE_PATH: "vendor/gems"
BUNDLE_WITHOUT: "development:test"
EOL
      bundle_config = "#{cache_area}/.bundle/config"
      FileUtils.mkdir_p(File.dirname(bundle_config))
      IO.write(bundle_config, text)
    end

    def copy_cache_gems
      vendor_gems = "#{@full_app_root}/vendor/gems"
      if File.exist?(vendor_gems)
        puts "Removing current vendor_gems from project"
        FileUtils.rm_rf(vendor_gems)
      end
      # Leave #{Jets.build_root}/vendor_gems behind to act as cache
      if File.exist?("#{cache_area}/vendor/gems")
        FileUtils.mkdir_p(File.dirname(vendor_gems))
        Jets::Util.cp_r("#{cache_area}/vendor/gems", vendor_gems)
      end
    end
  end
end
